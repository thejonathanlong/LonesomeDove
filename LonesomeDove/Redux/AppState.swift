//
//  AppState.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 4/13/21.
//

import Foundation
import PencilKit

struct AppState {
    lazy var drawingState: DrawingState = DrawingState()
    lazy var storyListState = StoryListState()
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
