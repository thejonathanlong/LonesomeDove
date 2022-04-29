//
//  ArrayExtensions.swift
//  LonesomeDove
//
//  Created on 4/29/22.
//

import Foundation

extension Array {
    func peek() -> Element? {
        last
    }
    
    mutating func push(_ element: Element) {
        append(element)
    }
}
