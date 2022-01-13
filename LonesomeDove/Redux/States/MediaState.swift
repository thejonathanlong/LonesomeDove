//
//  MediaState.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 12/22/21.
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
