//
//  AppState.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 4/13/21.
//

import Foundation
import PencilKit
import Media

struct AppState {
    lazy var drawingState: DrawingState = DrawingState()
    lazy var storyListState = StoryListState()
    var mediaState = MediaState()
    
    var dataStore: DataStorable
    
    init(dataStore: DataStorable = DataStore(),
         dataStoreDelegate: DataStoreDelegate? = nil) {
        self.dataStore = dataStore
        self.dataStore.delegate = dataStoreDelegate
    }
}

struct DrawingState {
    var drawing = PKDrawing()
    
    func showDrawingView() {
        AppLifeCycleManager.shared.router.route(to: .newStory(DrawingViewModel(store: AppLifeCycleManager.shared.store)))
    }
}

struct StoryListState {
    func addOrRemoveFromFavorite(_ card: StoryCardViewModel) {
        card.isFavorite = !card.isFavorite
    }
}

struct MediaState {
    
    var recorder: RecordingController?

    mutating func startRecording(to URL: URL?) {
        defer {
            recorder?.startOrResumeRecording()
        }
        guard let _ = recorder,
              let _ = URL else {
            recorder = RecordingController(recordingURL: URL)
            return
        }
    }
    
    func pauseRecording() {
        recorder?.pauseRecording()
    }
}
