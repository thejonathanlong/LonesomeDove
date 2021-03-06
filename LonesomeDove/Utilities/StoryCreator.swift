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

    enum CreatorError: LocalizedError {
        case emptyName
    }

    func createStory(from pages: [Page],
                     named name: String = "StoryTime-\(UUID())") async throws {
        guard !name.isEmpty else {
            throw CreatorError.emptyName
        }
        let outputURL = DataLocationModels.stories(name).URL()
        let tempAudioFileURL = DataLocationModels.temporaryAudio(UUID()).URL()
        
        let composition = AVMutableComposition()
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: .zero)
        
        
        try pages.map {
            $0.recordingURLs.compactMap { $0 }.isEmpty ? [Bundle.main.url(forResource: "silence-4s", withExtension: "m4a")!] : $0.recordingURLs.compactMap { $0 }
        }
        .flatMap { $0 }
        .forEach {
            let movie = AVURLAsset(url: $0, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
            if let movieAudioTrack = movie.tracks(withMediaType: .audio).first {
                print("JLO: appending \($0.lastPathComponent)")
                try audioTrack?.insertTimeRange(movie.movieDurationTimeRange, of: movieAudioTrack, at: composition.duration)
            }
        }
        
        let tempExporter = Exporter(outputURL: tempAudioFileURL)
        await tempExporter.export(asset: composition)
        
        var lastDuration: TimeInterval = 0.0
        var imageTimedMetadata = [AVTimedMetadataGroup]()
        for page in pages {
            let group = AVTimedMetadataGroup.timedMetadataGroup(with: page.image ?? UIImage(),
                                                    timeRange: CMTimeRange(start: lastDuration.cmTime, duration: page.duration.cmTime),
                                                    identifier: StoryTimeMediaIdentifiers.imageTimedMetadataIdentifier.rawValue)
            lastDuration = lastDuration + page.duration
            imageTimedMetadata.append(group)
        }

        var stringMetadata = [AVTimedMetadataGroup]()
        if !composition.tracks(withMediaType: .audio).isEmpty {
            let speechRecognizer = SpeechRecognizer()
            if let timedStrings = await speechRecognizer.generateTimeStrings(for: tempAudioFileURL) {
                let stringTimedMetadataGroup = AVTimedMetadataGroup.timedMetadataGroup(with: [timedStrings.formattedString], timeRange: CMTimeRange(start: .zero, duration: timedStrings.duration.cmTime), identifier: StoryTimeMediaIdentifiers.textFromSpeechMetadataIdentifier.rawValue)
                stringMetadata.append(stringTimedMetadataGroup)
            }
        }

        let exporter = Exporter(outputURL: outputURL)
        if let outputMovieURL = await exporter.export(asset: composition, timedMetadata: [imageTimedMetadata, stringMetadata], imageVideoTrack: (pages.compactMap { $0.image }, imageTimedMetadata.map { $0.timeRange })) {
            let outputMovie = AVMutableMovie(url: outputMovieURL)
            var existingMetadata = outputMovie.metadata

            let storyTimePosterMetadataItem = AVMutableMetadataItem()
            storyTimePosterMetadataItem.identifier = StoryTimeMediaIdentifiers.posterImageMetadataIdentifier.metadataIdentifier

            storyTimePosterMetadataItem.value = pages.compactMap { $0.image }.first?.pngData() as NSData?
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
