//
//  Page.swift
//  LonesomeDove
//  Created on 12/6/21.
//

import AVFoundation
import Collections
import Foundation
import PencilKit
import UIKit
import Media

struct Page: Identifiable, Equatable, Hashable {
    let id = UUID()
    var drawing: PKDrawing
    let index: Int
    var recordingURLs: OrderedSet<URL?>
    var stickers: Set<Sticker>
    var text: String?
    var generatedText: String = ""

    var duration: TimeInterval {
        recordingURLs
            .compactMap { $0 }
            .map { AVMovie(url: $0) }
            .map { $0.duration.seconds }
            .reduce(0) { $0 + $1 }
    }

    var image: UIImage?

    init(drawing: PKDrawing,
         index: Int,
         recordingURLs: OrderedSet<URL?>,
         stickers: Set<Sticker>) {
        self.drawing = drawing
        self.index = index
        self.recordingURLs = recordingURLs
        self.stickers = stickers
    }

    init?(pageManagedObject: PageManagedObject) {
        guard let illustration = pageManagedObject.illustration,
              let drawing = try? PKDrawing(data: illustration),
              let lastPathComponents = pageManagedObject.audioLastPathComponents as? [String],
              let stickerManagedObjects = pageManagedObject.stickers as? Set<StickerManagedObject>
        else {
                  return nil
              }
        self.drawing = drawing
        self.index = Int(pageManagedObject.number)
        self.recordingURLs = OrderedSet(lastPathComponents.map { DataLocationModels.recordings(UUID()).containingDirectory().appendingPathComponent($0)
        })
        self.stickers = Set(stickerManagedObjects.compactMap { Sticker(sticker: $0, pageIndex: Int(pageManagedObject.number)) })
    }

    func hash(into hasher: inout Hasher) {
        index.hash(into: &hasher)
    }

    public static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.drawing == rhs.drawing && lhs.index == rhs.index && lhs.text == rhs.text
    }
}
