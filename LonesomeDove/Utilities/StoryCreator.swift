//
//  StoryCreator.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 12/5/21.
//

import AVFoundation
import Foundation

class StoryCreator {
//    func createStory(from pages: [Page]) {
//        let url = FileManager.default.documentsDirectory.appendingPathComponent("StoryTime-AudioTrack-\(UUID())").appendingPathExtension("aac")
//        var movie = AVMutableMovie()
//        guard let audioTrack = movie.addMutableTrack(withMediaType: .audio, copySettingsFrom: nil, options: nil) { else return }
//        
//        audioTrack.mediaDataStorage = AVMediaDataStorage(url: url, options: nil)
//        
//        let recordedAudioTrack = pages
//            .map { $0.recordingURLs }
//            .flatMap { $0 }
//            .compactMap { $0 }
//            .reduce(audioTrack) { partialAudioTrack, nextURL in
//                let movie = AVMovie(url: nextURL, options: nil)
//                if let audioTrack = movie.tracks(withMediaType: .audio).first {
//                    partialAudioTrack.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: movie.duration), of: audioTrack, at: partialAudioTrack.timeRange.end, copySampleData: true)
//                }
//            }
//        
//    }
//    
//    func write(from movie: AVMovie, pages: [Page], to url: URL) {
//        let outputURL = FileManager.default.documentsDirectory.appendingPathComponent("StoryTime-AudioTrack-\(UUID())").appendingPathExtension("aac")
//        
//        
//        let assetReader = AVAssetReader(asset: movie)
//        let audioTrackOutput = AVAssetReaderTrackOutput(track: movie.tracks(withMediaType: .audio)[0], outputSettings: nil)
//        assetReader.add(audioTrackOutput)
//        
//        while audioTrackOutput
//        
//        let assetWriter = AVAssetWriter(outputURL: outputURL, fileType: .mov)
//        
//        let timedMetadataAdaptor = AVAssetWriterInputMetadataAdaptor(assetWriterInput: AVAssetWriterInput(mediaType: .metadata, outputSettings: nil))
//        timedMetadataAdaptor.append(<#T##timedMetadataGroup: AVTimedMetadataGroup##AVTimedMetadataGroup#>)
//        assetWriter.add(<#T##inputGroup: AVAssetWriterInputGroup##AVAssetWriterInputGroup#>)
//    }
}
