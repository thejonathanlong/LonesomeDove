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
   
}

enum DrawingAction {
    case update(PKDrawing)
}
