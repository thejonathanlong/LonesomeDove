//
//  DrawingComponent.swift
//  LonesomeDove
//
//  Created on 2/6/22.
//

import Foundation
import UIKit

struct Sticker: StickerDisplayable, Hashable {
    var stickerImage: UIImage?
    let stickerData: Data
    let creationDate: Date
    let position: CGPoint
    
    init(stickerData: Data,
         creationDate: Date,
         stickerImage: UIImage?,
         position: CGPoint) {
        self.stickerData = stickerData
        self.creationDate = creationDate
        self.stickerImage = stickerImage
        self.position = position
    }
    
    init?(sticker: StickerManagedObject) {
        guard let illustrationData = sticker.drawingData,
              let imageData = sticker.imageData,
              let position = sticker.position,
              let creationDate = sticker.creationDate else {
                  return nil
              }
        self.init(stickerData: illustrationData,
                  creationDate: creationDate,
                  stickerImage: UIImage(data: imageData),
                  position: NSCoder.cgPoint(for: position))
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(stickerImage)
        hasher.combine(stickerData)
        hasher.combine(creationDate)
        hasher.combine(position.x)
        hasher.combine(position.y)
    }
}
