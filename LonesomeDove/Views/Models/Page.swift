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
    var text: PageText? = nil

    var duration: TimeInterval {
        // If there is not a recording then we use a two second duration.
        // Stories with no audio are fine.
        let nonNilURLs = recordingURLs
            .compactMap { $0 }
        guard !nonNilURLs.isEmpty else { return LonesomeDoveConstants.PageConstants.defaultPageDuration.rawValue }
        return nonNilURLs
            .map { AVMovie(url: $0) }
            .map { $0.duration.seconds }
            .reduce(0) { $0 + $1 }
    }

    var image: UIImage?

    init(drawing: PKDrawing,
         index: Int,
         recordingURLs: OrderedSet<URL?>,
         stickers: Set<Sticker>,
         pageText: PageText?) {
        self.drawing = drawing
        self.index = index
        self.recordingURLs = recordingURLs
        self.stickers = stickers
        self.text = pageText
    }

    init?(pageManagedObject: PageManagedObject) {
        guard let illustration = pageManagedObject.illustration,
              let drawing = try? PKDrawing(data: illustration),
              let lastPathComponents = pageManagedObject.audioLastPathComponents as? [String],
              let stickerManagedObjects = pageManagedObject.stickers as? Set<StickerManagedObject>
        else { return nil }
        
        self.drawing = drawing
        self.index = Int(pageManagedObject.number)
        self.recordingURLs = OrderedSet(lastPathComponents.map { DataLocationModels.recordings(UUID()).containingDirectory().appendingPathComponent($0)
        })
        self.stickers = Set(stickerManagedObjects.compactMap {
            Sticker(sticker: $0, pageIndex: Int(pageManagedObject.number))
        })
        
        if let pageText = pageManagedObject.text,
           let text = pageText.text,
           let type = pageText.type,
           let textType = PageText.TextType(rawValue: type),
           let positionString = pageText.position {
            self.text = PageText(text: text,
                                 type: textType,
                                 position: NSCoder.cgPoint(for: positionString))
        }
    }

    func hash(into hasher: inout Hasher) {
        index.hash(into: &hasher)
    }

    public static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.index == rhs.index
    }
    
    mutating func update(text: String, type: PageText.TextType, position: CGPoint?) {
        if position == nil && self.text?.position != nil {
            self.text = PageText(text: text, type: type, position: self.text?.position)
        } else {
            self.text = PageText(text: text, type: type, position: position)
        }
    }
}
