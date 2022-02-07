//
//  SavedDrawingState.swift
//  LonesomeDove
//
//  Created on 2/6/22.
//

import UIKit

enum SavedDrawingAction {
    case save(UIImage)
    case fetchSavedDrawings
    case updateSavedDrawings([SavedDrawing])
}

struct SavedDrawingState {
    var savedDrawings: [SavedDrawing]
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
            state.savedDrawingState.savedDrawings = newSavedDrawings
    }
}
