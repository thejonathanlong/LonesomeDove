//
//  MediaState.swift
//  LonesomeDove
//  Created on 12/22/21.
//

import Foundation
import Media

enum RecordingAction {
    case startOrResumeRecording(URL?)
    case pauseRecording
    case finishRecording
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
