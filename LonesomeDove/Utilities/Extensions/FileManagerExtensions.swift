//
//  FileManagerExtensions.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 2/1/22.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
