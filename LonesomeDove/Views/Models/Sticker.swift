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
    var position: CGPoint
    var storyName: String?
    var id: UUID?
    var dateAdded: Date?

    init(stickerData: Data,
         creationDate: Date,
         stickerImage: UIImage?,
         position: CGPoint,
         pageIndex: Int?,
         storyName: String?,
         id: UUID,
         dateAdded: Date?) {
        self.stickerData = stickerData
        self.creationDate = creationDate
        self.stickerImage = stickerImage
        self.position = position
        self.pageIndex = pageIndex
        self.storyName = storyName
        self.id = id
        self.dateAdded = dateAdded
        self.pageIndex = pageIndex
    }

    init?(sticker: StickerManagedObject, pageIndex: Int?, storyName: String? = nil) {
        guard let illustrationData = sticker.drawingData,
              let imageData = sticker.imageData,
              let position = sticker.position,
              let id = sticker.id,
              let creationDate = sticker.creationDate else {
                  return nil
              }
        self.init(stickerData: illustrationData,
                  creationDate: creationDate,
                  stickerImage: UIImage(data: imageData),
                  position: NSCoder.cgPoint(for: position),
                  pageIndex: pageIndex,
                  storyName: storyName ?? sticker.draft?.title,
                  id: id,
                  dateAdded: sticker.dateAdded)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(stickerImage)
        hasher.combine(stickerData)
        hasher.combine(creationDate)
        hasher.combine(position.x)
        hasher.combine(position.y)
        hasher.combine(pageIndex)
        hasher.combine(id)
        hasher.combine(dateAdded)
    }
}
