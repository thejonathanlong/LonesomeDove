//
//  SavedDrawingState.swift
//  LonesomeDove
//
//  Created on 2/6/22.
//

import Combine
import UIKit

enum SavedDrawingAction {
    case save(UIImage)
    case fetchSavedDrawings
    case updateSavedDrawings([SavedDrawing])
    case showSavedDrawingDrawer
}

struct SavedDrawingState {
    var savedDrawings = CurrentValueSubject<Array<SavedDrawing>, Never>([])
    
    func showDrawer() {
        AppLifeCycleManager.shared.router.route(to: .showSavedDrawings(savedDrawings.value))
    }
}

func savedDrawingReducer(state: inout AppState, action: SavedDrawingAction) {
    switch action {
        case .save(let image):
            if let data = image.pngData() {
                state.dataStore.addSaved(drawingData: data)
            }
        
        case .fetchSavedDrawings:
            break
        
        case .updateSavedDrawings(let newSavedDrawings):
            state.savedDrawingState.savedDrawings.value = newSavedDrawings
        
        case .showSavedDrawingDrawer:
            state.savedDrawingState.showDrawer()
        
    }
}
