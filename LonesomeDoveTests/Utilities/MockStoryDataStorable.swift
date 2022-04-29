//
//  MockStoryDataStorable.swift
//  LonesomeDoveTests
//
//  Created on 4/14/22.
//

import CoreGraphics
@testable import LonesomeDove
import Foundation

class MockStoryDataStorable: StoryDataStorable {
    var didSaveHandler: () -> Void
    
    init(didSaveHandler: @escaping () -> Void) {
        self.didSaveHandler = didSaveHandler
    }
    
    var delegate: DataStoreDelegate?
    
    func addStory(named: String, location: URL, duration: TimeInterval, numberOfPages: Int, imageData: Data?) -> StoryManagedObject? {
        return nil
    }
    
    func deleteStory(named: String) { }
    
    func addDraft(named: String, pages: [Page], stickers: [StickerDisplayable]) -> DraftStoryManagedObject? {
        return nil
    }
    
    func deleteDraft(named: String) { }
    
    func addSticker(drawingData: Data, imageData: Data?, creationDate: Date, position: CGPoint) -> StickerManagedObject? {
        return nil
    }
    
    func fetchDraftsAndStories() async -> [StoryCardViewModel] {
        return []
    }
    
    func fetchPages(for story: StoryCardViewModel) async -> [Page] {
        return []
    }
    
    func fetchStickers() async -> [Sticker] {
        return []
    }
    
    func updateDraft(named: String, newName: String?, pages: [Page]) async { }
    
    func save() {
        didSaveHandler()
    }
}
