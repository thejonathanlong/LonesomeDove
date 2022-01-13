//
//  Page.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 12/6/21.
//

import AVFoundation
import Foundation
import PencilKit
import UIKit

struct Page: Identifiable, Equatable {
    let id = UUID()
    var drawing: PKDrawing
    let index: Int
    var recordingURLs: [URL?]

    public static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.id == rhs.id
    }

    var duration: TimeInterval {
        recordingURLs
            .compactMap { $0 }
            .map { AVMovie(url: $0) }
            .map { $0.duration.seconds }
            .reduce(0) { $0 + $1 }
    }

//    var image: UIImage {
//        drawing.image(from: drawing.bounds, scale: 1.0)
//    }

    var image: UIImage?
}
