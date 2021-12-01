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
        case .update(let _):
//            state.drawingState.drawing = newDrawing
            break
            
        case .nextPage(let currentDrawing):
            state.drawingState.addNextPage(drawing: currentDrawing)
            break
            
        case .previousPage(let currentDrawing):
            state.drawingState.goToPreviousPage(currentDrawing: currentDrawing)
            break
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
            state.mediaState.startRecording(to: FileManager.default.documentsDirectory.appendingPathComponent("StoryTime-\(UUID())").appendingPathExtension("aac"))
            
        case .pauseRecording:
            state.mediaState.pauseRecording()
            
        case .finishRecording:
            state.mediaState.finishRecording()
    }
}
