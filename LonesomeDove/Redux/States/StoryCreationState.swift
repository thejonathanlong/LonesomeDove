//
//  StoryCreationState.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 12/22/21.
//

import Combine
import Foundation
import PencilKit
import Media

struct StoryCreationState {
    
    var pages = [Page]()
    
    var currentPagePublisher = CurrentValueSubject<Page, Never>(Page(drawing: PKDrawing(), index: 0, recordingURLs: []))
    
    var currentPage: Page {
        get {
            currentPagePublisher.value
        }
        set(newPage) {
            currentPagePublisher.value = newPage
        }
    }
    
    func showDrawingView() {
        AppLifeCycleManager.shared.router.route(to: .newStory(StoryCreationViewModel(store: AppLifeCycleManager.shared.store)))
    }
    
    mutating func updateCurrentPage(currentDrawing: PKDrawing, recordingURL: URL?, from view: UIView) {
        currentPage.drawing.append(currentDrawing)
        currentPage.recordingURLs.append(recordingURL)
        currentPage.image = view.snapshot()
    }
    
    mutating func moveToNextPage(currentDrawing: PKDrawing, recordingURL: URL?, from view: UIView) {
        updateCurrentPage(currentDrawing: currentDrawing, recordingURL: recordingURL, from: view)
        
        if pages.contains(currentPage) {
            pages[currentPage.index] = currentPage
        } else {
            pages.append(currentPage)
        }
        
        
        if currentPage.index + 1 >= pages.count {
            currentPage = Page(drawing: PKDrawing(), index: currentPage.index + 1, recordingURLs: [])
        } else {
            currentPage = pages[currentPage.index + 1]
        }
    }
    
    mutating func moveToPreviousPage(currentDrawing: PKDrawing, recordingURL: URL?, from view: UIView) {
        updateCurrentPage(currentDrawing: currentDrawing, recordingURL: recordingURL, from: view)
        
        let currentIndex = currentPage.index
        if currentIndex < pages.count {
            pages[currentIndex] = currentPage
        } else {
            pages.append(currentPage)
        }
        
        if currentPage.index > 0 {
            currentPage = pages[currentIndex - 1]
        }
    }
    
    func createStory(named name: String) async throws {
        let creator = StoryCreator(store: nil)
        try await creator.createStory(from: pages + [currentPage], named: name)
        
    }
    
    func cancelAndDeleteCurrentStory(_ completion: () -> Void) {
        pages
            .map { $0.recordingURLs}
            .flatMap { $0 }
            .compactMap { $0 }
            .filter { FileManager.default.fileExists(atPath: $0.path) }
            .forEach { try? FileManager.default.removeItem(at: $0) }
        
        //TODO: Once we are saving drafts to the database we need to remove the draft as well
        
        completion()
    }
}

extension UIView {
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return snapshotImage
    }
}
