//
//  AppState.swift
//  LonesomeDove
//  Created on 4/13/21.
//

import Combine
import Foundation
import PencilKit
import Media

enum AppAction: CustomStringConvertible {
    case storyCreation(StoryCreationAction)
    case storyCard(StoryListAction)
    case dataStore(DataStoreAction)
    case recording(RecordingAction)
    case sticker(StickerAction)
    case failure(Error)

    var description: String {
        switch self {
        case .storyCreation(let storyCreationAction):
            return storyCreationAction.description

        case .storyCard(let storyListAction):
            return storyListAction.description

        case .dataStore(let dataStoreAction):
            return dataStoreAction.description

        case .recording(let recordingAction):
            return recordingAction.description

        case .sticker(let stickerAction):
            return stickerAction.description

        case .failure(let error):
            return error.localizedDescription
        }
    }
}

struct AppState {
    var storyListState: StoryListState
    var storyCreationState: StoryCreationState
    var mediaState = MediaState()
    var stickerState = StickerState()

    var dataStore: StoryDataStorable

    init(dataStore: StoryDataStorable = DataStore(),
         dataStoreDelegate: DataStoreDelegate? = nil) {
        self.dataStore = dataStore
        self.dataStore.delegate = dataStoreDelegate
        self.storyListState = StoryListState(dataStore: dataStore, cardState: .normal)
        self.storyCreationState = StoryCreationState(dataStore: dataStore)
    }
}
