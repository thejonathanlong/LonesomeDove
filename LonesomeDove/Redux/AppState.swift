//
//  AppState.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 4/13/21.
//

import Foundation
import PencilKit

struct AppState {
    lazy var drawingState = DrawingState()
    lazy var storyListState = StoryListState()
}

struct DrawingState {
    var drawing = PKDrawing()
}

struct StoryListState {
    func addOrRemoveFromFavorite(_ card: StoryCardViewModel) {
        card.isFavorite = !card.isFavorite
    }
}
