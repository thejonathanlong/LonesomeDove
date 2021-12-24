//
//  StoryCreator.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 12/5/21.
//

import AVFoundation
import Foundation

class StoryCreator {
    var store: AppStore?
    
    init(store: AppStore? = nil) {
        self.store = store
    }
    
    func createStory(from pages: [Page]) {
        let url = FileManager.default.documentsDirectory.appendingPathComponent("StoryTime-AudioTrack-\(UUID())").appendingPathExtension("aac")
        var movie = AVMutableMovie()
        guard let audioTrack = movie.addMutableTrack(withMediaType: .audio, copySettingsFrom: nil, options: nil) else { return }
        
        audioTrack.mediaDataStorage = AVMediaDataStorage(url: url, options: nil)
        
        let recordedAudioTrack = pages
            .map { $0.recordingURLs }
            .flatMap { $0 }
            .compactMap { $0 }
            .reduce(audioTrack) { partialAudioTrack, nextURL in
                let movie = AVMovie(url: nextURL, options: nil)
                if let audioTrack = movie.tracks(withMediaType: .audio).first {
                    do {
                        try partialAudioTrack.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: movie.duration), of: audioTrack, at: partialAudioTrack.timeRange.end, copySampleData: true)
                    } catch let error {
                        // Dispatch to a storyCreation error.
//                        store?.dispatch(.)
                    }
                    
                }
                return partialAudioTrack
            }
        
    }
}
