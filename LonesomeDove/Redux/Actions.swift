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
}

enum DrawingAction {
    case update(PKDrawing)
}

enum StoryListAction {
    // The below case needs an associated object that is the viewModel conforming to StoryCardDisplayable
    case toggleFavorite(StoryCardViewModel)
    case newStory
    case readStory(StoryCardViewModel)
}

enum DataStoreAction {
    case save
    case failed(Error)
}

enum RecordingAction {
    case startRecording
    case pauseRecording
    case finishRecording
}
