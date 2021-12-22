//
//  Page.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 12/6/21.
//

import Foundation
import PencilKit

struct Page: Identifiable, Equatable {
    let id = UUID()
    var drawing: PKDrawing
    let index: Int
    var recordingURLs: [URL?]
}
