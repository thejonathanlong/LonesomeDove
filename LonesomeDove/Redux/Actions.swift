//
//  Actions.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 4/13/21.
//

import Foundation
import PencilKit

enum AppAction {
    case drawing(DrawingAction)
    case storyCard(StoryListAction)
    case dataStore(DataStoreAction)
    case recording(RecordingAction)
    case failure(Error)
}

enum DrawingAction {
    case update(PKDrawing)
    case nextPage(PKDrawing, URL?)
    case previousPage(PKDrawing, URL?)
}

enum StoryListAction {
    // The below case needs an associated object that is the viewModel conforming to StoryCardDisplayable
    case toggleFavorite(StoryCardViewModel)
    case newStory
    case readStory(StoryCardViewModel)
}

enum DataStoreAction {
    case save
//    case failed(Error)
}

enum RecordingAction {
    case startOrResumeRecording(URL?)
    case pauseRecording
    case finishRecording
}
