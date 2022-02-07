//
//  AppState.swift
//  LonesomeDove
//  Created on 4/13/21.
//

import Combine
import Foundation
import PencilKit
import Media

enum AppAction {
    case storyCreation(StoryCreationAction)
    case storyCard(StoryListAction)
    case dataStore(DataStoreAction)
    case recording(RecordingAction)
    case savedDrawing(SavedDrawingAction)
    case failure(Error)
}

struct AppState {
    var storyListState: StoryListState
    var storyCreationState: StoryCreationState = StoryCreationState()
    var mediaState = MediaState()
    lazy var savedDrawingState = SavedDrawingState()

    var dataStore: StoryDataStorable

    init(dataStore: StoryDataStorable = DataStore(),
         dataStoreDelegate: DataStoreDelegate? = nil) {
        self.dataStore = dataStore
        self.dataStore.delegate = dataStoreDelegate
        self.storyListState = StoryListState(dataStore: dataStore, cardState: .normal)
    }
}
