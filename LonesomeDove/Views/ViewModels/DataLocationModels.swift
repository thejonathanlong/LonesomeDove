//
//  DataLocationModels.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 12/30/21.
//

import Foundation

enum DataLocationModels {
    case temporaryAudio(UUID)
    case stories(String)
    case recordings(UUID)
    
    func URL() -> URL {
        switch self {
            case .temporaryAudio(let id):
                return containingDirectory().appendingPathComponent("StoryTime-AudioTrack-\(id))").appendingPathExtension("mp4")
                
            case .recordings(let id):
                return containingDirectory().appendingPathComponent("StoryTime-Recording-\(id)").appendingPathExtension("mp4")
                
            case .stories(let name):
                return containingDirectory().appendingPathComponent(name).appendingPathExtension("mov")
                
        }
    }
    
    func containingDirectory() -> URL {
        var containerURL = FileManager.documentsDirectory.appendingPathComponent("StoryTime-tmpAudioTracks")
        switch self {
            case .temporaryAudio(_):
                containerURL = FileManager.documentsDirectory.appendingPathComponent("StoryTime-tmpAudioTracks")
                
                
            case .recordings(_):
                containerURL = FileManager.documentsDirectory.appendingPathComponent("StoryTime-recordings")
                
                
            case .stories(_):
                containerURL = FileManager.documentsDirectory.appendingPathComponent("StoryTime-Stories")
                
        }
        
        createContainerDirectoryIfNeeded(at: containerURL)
        return containerURL
    }
    
    private func createContainerDirectoryIfNeeded(at url: URL) {
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
