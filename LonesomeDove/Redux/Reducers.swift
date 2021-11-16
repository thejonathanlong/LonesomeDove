//
//  Reducers.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 4/13/21.
//

import Foundation
import Media

typealias Reducer<State, Action> = (inout State, Action) -> Void

//MARK: - AppReducer
func appReducer(state: inout AppState, action: AppAction) -> Void {
    switch action {
        case .drawing(let drawingAction):
            drawingReducer(state: &state, action: drawingAction)
            
        case .storyCard(let storyCardAction):
            storyListReducer(state: &state, action: storyCardAction)
            
        case .dataStore(let dataStoreAction):
            dataStoreReducer(state: &state, action: dataStoreAction)
        case .recording(let recordingAction):
            recordingReducer(state: &state, action: recordingAction)
            
        case .failure(let error):
            // Routing to show/handle errors
//            switch error {
//                case RecordingController.RecordingError:
//                    break
//                default:
//                    break
//            }
            break
    }
}

func drawingReducer(state: inout AppState, action: DrawingAction) -> Void {
    switch action {
        case .update(let newDrawing):
            state.drawingState.drawing = newDrawing
    }
}

func storyListReducer(state: inout AppState, action: StoryListAction) -> Void {
    switch action {
        case .toggleFavorite(let storyCardViewModel):
            state.storyListState.addOrRemoveFromFavorite(storyCardViewModel)
            
        case .newStory:
            state.drawingState.showDrawingView()
            break
            
        case .readStory(let storyCardViewModel):
            break
    }
}

func dataStoreReducer(state: inout AppState, action: DataStoreAction) -> Void {
    switch action {
        case .save:
            state.dataStore.save()
            
    }
}

func recordingReducer(state: inout AppState, action: RecordingAction) -> Void {
    switch action {
        case .startOrResumeRecording:
            // Start the recording here...
            break
        case .pauseRecording:
            // Then stop it here...
            break
        case .finishRecording:
            // Now stitch the drawings and the recording to a .mov
            break
    }
}
