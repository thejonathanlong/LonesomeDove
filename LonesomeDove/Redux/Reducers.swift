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
        case .storyCreation(let drawingAction):
            storyCreationReducer(state: &state, action: drawingAction)
            
        case .storyCard(let storyCardAction):
            storyListReducer(state: &state, action: storyCardAction)
            
        case .dataStore(let dataStoreAction):
            dataStoreReducer(state: &state, action: dataStoreAction)
        
        case .recording(let recordingAction):
            recordingReducer(state: &state, action: recordingAction)
            
        case .failure(let error):
        print("JLO: THERE WAS AN ERROR!!! \(error)")
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

func storyCreationReducer(state: inout AppState, action: StoryCreationAction) -> Void {
    switch action {
        case .update(let currentDrawing, let recordingURL, let image):
            state.storyCreationState.updateCurrentPage(currentDrawing: currentDrawing, recordingURL: recordingURL, image: image)
        	break
            
        case .nextPage(let currentDrawing, let recordingURL, let image):
            state.storyCreationState.moveToNextPage(currentDrawing: currentDrawing, recordingURL: recordingURL, image: image)
            
        case .previousPage(let currentDrawing, let recordingURL, let image):
            state.storyCreationState.moveToPreviousPage(currentDrawing: currentDrawing, recordingURL: recordingURL, image: image)
        
    	case .cancelAndDeleteCurrentStory(let completion):
        	state.storyCreationState.cancelAndDeleteCurrentStory(completion)
        
        case .finishStory(let name):
            Task { [state] in
                try! await state.storyCreationState.createStory(named: name)
            }
    }
}

func storyListReducer(state: inout AppState, action: StoryListAction) -> Void {
    switch action {
        case .toggleFavorite(let storyCardViewModel):
            state.storyListState.addOrRemoveFromFavorite(storyCardViewModel)
            
        case .newStory:
            state.storyCreationState.showDrawingView()
            
        case .readStory(_):
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
        case .startOrResumeRecording(let recordingURL):
            state.mediaState.startRecording(to: recordingURL)
            
        case .pauseRecording:
            state.mediaState.pauseRecording()
            
        case .finishRecording:
            state.mediaState.finishRecording()
    }
}
