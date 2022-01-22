//
//  Page.swift
//  LonesomeDove
//  Created on 12/6/21.
//

import AVFoundation
import Foundation
import PencilKit
import UIKit

struct Page: Identifiable, Equatable, Hashable {
    let id = UUID()
    var drawing: PKDrawing
    let index: Int
    var recordingURLs: [URL?]

    var duration: TimeInterval {
        recordingURLs
            .compactMap { $0 }
            .map { AVMovie(url: $0) }
            .map { $0.duration.seconds }
            .reduce(0) { $0 + $1 }
    }

    var image: UIImage?

    init(drawing: PKDrawing, index: Int, recordingURLs: [URL?]) {
        self.drawing = drawing
        self.index = index
        self.recordingURLs = recordingURLs
    }

    init?(pageManagedObject: PageManagedObject) {
        guard let illustration = pageManagedObject.illustration,
              let drawing = try? PKDrawing(data: illustration),
              let lastPathComponents = pageManagedObject.audioLastPathComponents as? [String] else {
                  return nil
              }
        self.drawing = drawing
        self.index = Int(pageManagedObject.number)
        self.recordingURLs = lastPathComponents.map { DataLocationModels.recordings(UUID()).containingDirectory().appendingPathComponent($0)
        }
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
        index.hash(into: &hasher)
    }

    public static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.id == rhs.id
    }
}
