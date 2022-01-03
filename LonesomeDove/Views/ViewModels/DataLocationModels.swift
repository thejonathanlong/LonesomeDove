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
        switch self {
            case .temporaryAudio(_):
                return FileManager.documentsDirectory.appendingPathComponent("tmpAudioTracks")
                
            case .recordings(_):
                return FileManager.documentsDirectory.appendingPathComponent("recordings")
                
            case .stories(_):
                return FileManager.documentsDirectory.appendingPathComponent("Stories")
                
        }
        
    }
}
