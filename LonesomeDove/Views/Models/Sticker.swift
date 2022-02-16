//
//  DrawingComponent.swift
//  LonesomeDove
//
//  Created on 2/6/22.
//

import Foundation
import UIKit

struct Sticker: DrawingDisplayable {
    var drawingImage: UIImage?
    
    let illustrationData: Data
    let creationDate: Date
    
    init(illustrationData: Data, creationDate: Date) {
        self.illustrationData = illustrationData
        self.creationDate = creationDate
        self.drawingImage = UIImage(data: illustrationData)
    }
    
    init?(sticker: StickerManagedObject) {
        guard let illustrationData = sticker.data,
              let creationDate = sticker.creationDate else {
                  return nil
              }
        self.init(illustrationData: illustrationData, creationDate: creationDate)
    }
}
