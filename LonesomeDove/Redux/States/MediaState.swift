//
//  MediaState.swift
//  LonesomeDove
//  Created on 12/22/21.
//

import Foundation
import Media

enum RecordingAction: CustomStringConvertible {
    case startOrResumeRecording(URL?)
    case pauseRecording
    case finishRecording
    
    var description: String {
        var base = "RecordingAction "
        
        switch self {
        case .startOrResumeRecording(let url):
            base += "Start or Resume Recording url: \(url?.path ?? "nil")"
            
        case .pauseRecording:
            base += "Pause Recording"
            
        case .finishRecording:
            base += "Finish Recording"
        }
        
        return base
    }
}

struct MediaState {

    var recorder: RecordingController? = RecordingController()

    var currentRecordingURL: URL?

    mutating func startRecording(to URL: URL?) {
        if recorder == nil {
            recorder = RecordingController()
        }
        recorder?.recordingURL = URL
        currentRecordingURL = URL
        recorder?.startOrResumeRecording()
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

func recordingReducer(state: inout AppState, action: RecordingAction) {
    switch action {
        case .startOrResumeRecording(let recordingURL):
            state.mediaState.startRecording(to: recordingURL)

        case .pauseRecording:
            state.mediaState.pauseRecording()

        case .finishRecording:
            state.mediaState.finishRecording()
    }
}
