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
}

struct DrawingState {
    let drawing = PKDrawing()
}
