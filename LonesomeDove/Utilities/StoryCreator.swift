//
//  StoryCreator.swift
//  LonesomeDove
//  Created on 12/5/21.
//

import AVFoundation
import Foundation
import Media
import UIKit

enum StoryTimeMediaIdentifiers: String {
    case imageTimedMetadataIdentifier = "com.LonesomeDove.StoryTime.ImageIdentifier"
    case posterImageMetadataIdentifier = "com.LonesomeDove.StoryTime.PosterImage"
    case textFromSpeechMetadataIdentifier = "com.LonesomeDove.StoryTime.TextFromSpeech"
    case nameMetadataIdentifier = "com.LonesomeDove.StoryTime.Name"

    var metadataIdentifier: AVMetadataIdentifier {
        AVMetadataItem.identifier(forKey: rawValue, keySpace: .quickTimeMetadata)!
    }
}

class StoryCreator {
    var store: AppStore?

    init(store: AppStore? = nil) {
        self.store = store
    }

    func createStory(from pages: [Page],
                     named name: String = "StoryTime-\(UUID())") async throws {

        let outputURL = DataLocationModels.stories(name).URL()
        let tempAudioFileURL = DataLocationModels.temporaryAudio(UUID()).URL()
        let mutableMovie = AVMutableMovie()
        mutableMovie.defaultMediaDataStorage = AVMediaDataStorage(url: tempAudioFileURL, options: nil)

        try pages
            .map { $0.recordingURLs }
            .flatMap { $0 }
            .compactMap { $0 }
            .forEach { nextURL in
                let movie = AVURLAsset(url: nextURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
               try mutableMovie.insertTimeRange(movie.movieDurationTimeRange, of: movie, at: mutableMovie.duration, copySampleData: true)

            }

        try mutableMovie.writeHeader(to: tempAudioFileURL, fileType: .mp4, options: .addMovieHeaderToDestination)

        var lastDuration: TimeInterval = 0.0
        var imageTimedMetadata = [AVTimedMetadataGroup]()
        for page in pages {
            guard let pageImage = page.image else { continue }
            let group = AVTimedMetadataGroup.timedMetadataGroup(with: pageImage,
                                                    timeRange: CMTimeRange(start: lastDuration.cmTime, duration: page.duration.cmTime),
                                                    identifier: StoryTimeMediaIdentifiers.imageTimedMetadataIdentifier.rawValue)
            lastDuration = lastDuration + page.duration
            imageTimedMetadata.append(group)
        }

        var stringMetadata = [AVTimedMetadataGroup]()
        if !mutableMovie.tracks(withMediaType: .audio).isEmpty {
            let speechRecognizer = SpeechRecognizer(url: tempAudioFileURL)

            if let timedStrings = await speechRecognizer.generateTimedStrings() {
                let stringTimedMetadataGroup = AVTimedMetadataGroup.timedMetadataGroup(with: timedStrings.formattedString, timeRange: CMTimeRange(start: .zero, duration: timedStrings.duration.cmTime), identifier: StoryTimeMediaIdentifiers.textFromSpeechMetadataIdentifier.rawValue)
                stringMetadata.append(stringTimedMetadataGroup)
            }
        }

        let exporter = Exporter(outputURL: outputURL)
        if let outputMovieURL = await exporter.export(asset: mutableMovie, timedMetadata: [imageTimedMetadata, stringMetadata], imageVideoTrack: (pages.compactMap { $0.image }, imageTimedMetadata.map { $0.timeRange })) {
            let outputMovie = AVMutableMovie(url: outputMovieURL)
            var existingMetadata = outputMovie.metadata

            let storyTimePosterMetadataItem = AVMutableMetadataItem()
            storyTimePosterMetadataItem.identifier = StoryTimeMediaIdentifiers.posterImageMetadataIdentifier.metadataIdentifier
            storyTimePosterMetadataItem.value = pages.first?.image?.pngData() as NSData?
            storyTimePosterMetadataItem.dataType = kCMMetadataBaseDataType_PNG as String

            existingMetadata.append(storyTimePosterMetadataItem)

            let nameMetadata = AVMutableMetadataItem()
            nameMetadata.identifier = StoryTimeMediaIdentifiers.nameMetadataIdentifier.metadataIdentifier
            nameMetadata.value = name as NSString
            nameMetadata.dataType = kCMMetadataBaseDataType_UTF8 as String

            existingMetadata.append(nameMetadata)

            outputMovie.metadata = existingMetadata

            try outputMovie.writeHeader(to: outputMovieURL, fileType: .mov, options: AVMovieWritingOptions.addMovieHeaderToDestination)
        }

        try FileManager.default.removeItem(at: tempAudioFileURL)
    }
}

extension TimeInterval {
    var cmTime: CMTime {
        switch self {
            case 0.0:
                return .zero
            case .nan:
                return .invalid
            default:
                return CMTime(seconds: self, preferredTimescale: CMTimeScale(60000))
        }
    }
}

extension AVURLAsset {
    var movieDurationTimeRange: CMTimeRange {
        CMTimeRange(start: .zero, duration: duration)
    }
}
