//
//  MockFileManageable.swift
//  LonesomeDoveTests
//
//  Created on 4/6/22.
//

@testable import LonesomeDove
import Foundation

class MockFileManageable: FileManageable {
    
    let removeItemHandler: (URL) -> Void
    
    let fileExists: (String) -> Bool
    
    init(removeItemHandler: @escaping (URL) -> Void,
         fileExists: @escaping  (String) -> Bool) {
        self.removeItemHandler = removeItemHandler
        self.fileExists = fileExists
    }
    
    func removeItem(at URL: URL) throws {
        self.removeItemHandler(URL)
    }
    
    func fileExists(atPath path: String) -> Bool {
        self.fileExists(path)
    }
}
