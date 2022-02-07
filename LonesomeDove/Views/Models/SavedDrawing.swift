//
//  DrawingComponent.swift
//  LonesomeDove
//
//  Created on 2/6/22.
//

import Foundation

struct SavedDrawing {
    let illustrationData: Data
    let creationDate: Date
    
    init(illustrationData: Data, creationDate: Date) {
        self.illustrationData = illustrationData
        self.creationDate = creationDate
    }
    
    init?(savedDrawing: SavedDrawingManagedObject) {
        guard let illustrationData = savedDrawing.illustrationData,
              let creationDate = savedDrawing.creationDate else {
                  return nil
              }
        self.init(illustrationData: illustrationData, creationDate: creationDate)
    }
}