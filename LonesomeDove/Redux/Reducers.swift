//
//  Reducers.swift
//  LonesomeDove
//  Created on 4/13/21.
//

import Foundation
import Media

typealias Reducer<State, Action> = (inout State, Action) -> Void

// MARK: - AppReducer
func appReducer(state: inout AppState, action: AppAction) {
    switch action {
        case .storyCreation(let drawingAction):
            storyCreationReducer(state: &state, action: drawingAction)

        case .storyCard(let storyCardAction):
            storyListReducer(state: &state, action: storyCardAction)

        case .dataStore(let dataStoreAction):
            dataStoreReducer(state: &state, action: dataStoreAction)

        case .recording(let recordingAction):
            recordingReducer(state: &state, action: recordingAction)

        case .sticker(let stickerAction):
            stickerReducer(state: &state, action: stickerAction)

        case .failure:
            AppLifeCycleManager.shared.router.route(to: .warning(.generic))
            break
    }
}

func dataStoreReducer(state: inout AppState, action: DataStoreAction) {
    switch action {
        case .save:
            state.dataStore.save()

        case .addStory(let name, let location, let duration, let numberOfPages):
            state.dataStore.addStory(named: name, location: location, duration: duration, numberOfPages: numberOfPages)

        case .addDraft(let name, let pages, let stickers):
            switch state.storyCreationState.creationState {
                case .new:
                    state.dataStore.addDraft(named: name, pages: pages, stickers: stickers)
                case .editing(let oldName):
                    Task { [state] in
                        await state.dataStore.updateDraft(named: oldName, newName: name, pages: pages)
                    }
            }

    }
}
