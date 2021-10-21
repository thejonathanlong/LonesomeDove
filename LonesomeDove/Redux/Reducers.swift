//
//  Reducers.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 4/13/21.
//

import Foundation

typealias Reducer<State, Action> = (inout State, Action) -> Void

//MARK: - AppReducer
func appReducer(state: inout AppState, action: AppAction) -> Void {
    switch action {
        case .drawing(let drawingAction):
            drawingReducer(state: &state, action: drawingAction)
    }
}

func drawingReducer(state: inout AppState, action: DrawingAction) -> Void {
    switch action {
        case .update(let newDrawing):
            print("Drawing updated")
    }
}
