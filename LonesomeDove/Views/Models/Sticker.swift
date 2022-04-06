//
//  DrawingComponent.swift
//  LonesomeDove
//
//  Created on 2/6/22.
//

import Foundation
import UIKit

struct Sticker: StickerDisplayable, Hashable, Equatable {
    var pageIndex: Int?
    var stickerImage: UIImage?
    let stickerData: Data
    let creationDate: Date
    let position: CGPoint

    init(stickerData: Data,
         creationDate: Date,
         stickerImage: UIImage?,
         position: CGPoint,
         pageIndex: Int?) {
        self.stickerData = stickerData
        self.creationDate = creationDate
        self.stickerImage = stickerImage
        self.position = position
        self.pageIndex = pageIndex
    }

    init?(sticker: StickerManagedObject, pageIndex: Int?) {
        guard let illustrationData = sticker.drawingData,
              let imageData = sticker.imageData,
              let position = sticker.position,
              let creationDate = sticker.creationDate else {
                  return nil
              }
        self.init(stickerData: illustrationData,
                  creationDate: creationDate,
                  stickerImage: UIImage(data: imageData),
                  position: NSCoder.cgPoint(for: position),
                  pageIndex: pageIndex)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(stickerImage)
        hasher.combine(stickerData)
        hasher.combine(creationDate)
        hasher.combine(position.x)
        hasher.combine(position.y)
        hasher.combine(pageIndex)
    }
}
