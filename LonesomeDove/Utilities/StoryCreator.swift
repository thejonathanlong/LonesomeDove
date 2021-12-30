//
//  StoryCreator.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 12/5/21.
//

import AVFoundation
import Foundation
import Media
import UIKit

enum StoryTimeMediaIdentifiers: String {
    case imageTimedMetadataIdentifier = "com.LonesomeDove.StoryTime.ImageIdentifier"
}

class StoryCreator {
    var store: AppStore?
    
    init(store: AppStore? = nil) {
        self.store = store
    }
    
    func createStory(from pages: [Page],
                     named name: String = "StoryTime-\(UUID())") async throws {
        
        let outputURL = FileManager.default.documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        let tempAudioFileURL = FileManager.default.documentsDirectory.appendingPathComponent("StoryTime-AudioTrack-\(UUID())").appendingPathExtension("mp4")
        let mutableMovie = AVMutableMovie()
        mutableMovie.defaultMediaDataStorage = AVMediaDataStorage(url: tempAudioFileURL, options: nil)
        
        try pages
            .map { $0.recordingURLs }
            .flatMap { $0 }
            .compactMap { $0 }
            .forEach { nextURL in
                let movie = AVURLAsset(url: nextURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey : true])
               try mutableMovie.insertTimeRange(movie.movieDurationTimeRange, of: movie, at: mutableMovie.duration, copySampleData: true)
                
            }
        
        try mutableMovie.writeHeader(to: tempAudioFileURL, fileType: .mp4, options: .addMovieHeaderToDestination)
        
        var lastDuration: TimeInterval = 0.0
        var imageTimedMetadata = Array<AVTimedMetadataGroup>()
        for page in pages {
            guard let pageImage = page.image else { continue }
            let group = AVTimedMetadataGroup.timedMetadataGroup(with: pageImage,
                                                    timeRange: CMTimeRange(start: lastDuration.cmTime, duration: page.duration.cmTime),
                                                    identifier: StoryTimeMediaIdentifiers.imageTimedMetadataIdentifier.rawValue)
            lastDuration = lastDuration + page.duration
            imageTimedMetadata.append(group)
        }
        
        
        let exporter = Exporter(outputURL: outputURL)
        await exporter.export(asset: mutableMovie, timedMetadata: imageTimedMetadata, imageVideoTrack: (pages.compactMap { $0.image } , imageTimedMetadata.map { $0.timeRange }))
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
