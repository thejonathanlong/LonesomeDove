//
//  PageText.swift
//  LonesomeDove
//
//  Created on 3/31/22.
//

import CoreGraphics
import Foundation

struct PageText: Equatable {
    
    enum TextType: String {
        case generated = "GENERATED"
        case modified = "MODIFIED"
    }
    
    var text: String
    let type: TextType
    var position: CGPoint?
    var textFromSpeech: [URL: String] = [:]
}
