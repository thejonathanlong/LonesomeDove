//
//  MediaState.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 12/22/21.
//

import Foundation
import Media

struct MediaState {
        
    var recorder: RecordingController?

    var currentRecordingURL: URL?
    
    mutating func startRecording(to URL: URL?) {
        defer {
            recorder?.startOrResumeRecording()
        }
        guard let _ = recorder,
              let _ = URL else {
                  recorder = RecordingController(recordingURL: URL)
                  currentRecordingURL = URL
                  return
        }
    }
    
    func pauseRecording() {
        recorder?.pauseRecording()
    }
    
    mutating func finishRecording() {
        recorder?.finishRecording()
        currentRecordingURL = nil
        recorder = nil
    }
}
