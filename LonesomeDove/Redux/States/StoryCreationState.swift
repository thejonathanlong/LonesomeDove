//
//  StoryCreationState.swift
//  LonesomeDove
//  Created on 12/22/21.
//

import Combine
import Foundation
import PencilKit
import Media

enum StoryCreationAction {
    case update(PKDrawing, URL?, UIImage?)
    case nextPage(PKDrawing, URL?, UIImage?)
    case previousPage(PKDrawing, URL?, UIImage?)
    case cancelAndDeleteCurrentStory(() -> Void)
    case finishStory(String)
}

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

    mutating func updateCurrentPage(currentDrawing: PKDrawing, recordingURL: URL?, image: UIImage?) {
        currentPage.drawing.append(currentDrawing)
        currentPage.recordingURLs.append(recordingURL)
        currentPage.image = image

        if pages.contains(currentPage) {
            pages[currentPage.index] = currentPage
        } else {
            pages.append(currentPage)
        }
    }

    mutating func moveToNextPage(currentDrawing: PKDrawing, recordingURL: URL?, image: UIImage?) {
        updateCurrentPage(currentDrawing: currentDrawing, recordingURL: recordingURL, image: image)

        if currentPage.index + 1 >= pages.count {
            currentPage = Page(drawing: PKDrawing(), index: currentPage.index + 1, recordingURLs: [])
        } else {
            currentPage = pages[currentPage.index + 1]
        }
    }

    mutating func moveToPreviousPage(currentDrawing: PKDrawing, recordingURL: URL?, image: UIImage?) {
        updateCurrentPage(currentDrawing: currentDrawing, recordingURL: recordingURL, image: image)

        let currentIndex = currentPage.index
        if currentPage.index > 0 {
            currentPage = pages[currentIndex - 1]
        }
    }

    func createStory(named name: String) async throws {
        let creator = StoryCreator(store: nil)
        try await creator.createStory(from: pages, named: name)
    }

    func cancelAndDeleteCurrentStory(_ completion: () -> Void) {
        pages
            .map { $0.recordingURLs}
            .flatMap { $0 }
            .compactMap { $0 }
            .filter { FileManager.default.fileExists(atPath: $0.path) }
            .forEach { try? FileManager.default.removeItem(at: $0) }

        // TODO: Once we are saving drafts to the database we need to remove the draft as well

        completion()
    }

    func initializeWithDraft() {
        /*
         var pages = [Page]()
         for pageManagedObject in pageManagedObjects {
             guard let drawingData = pageManagedObject.illustration,
                   let drawing = try? PKDrawing(data: drawingData),
                   let lastPathCompnents = pageManagedObject.audioLastPathComponents as? [String]
             else {
                 continue
             }

             let recordingURLs = lastPathCompnents.map { lpc in
                 DataLocationModels.recordings(UUID()).containingDirectory().appendingPathComponent(lpc)
             }
             pages.append( Page(drawing: drawing, index: Int(pageManagedObject.number), recordingURLs: recordingURLs, image: nil))
         }
         */
    }
}

func storyCreationReducer(state: inout AppState, action: StoryCreationAction) {
    switch action {
        case .update(let currentDrawing, let recordingURL, let image):
            state.storyCreationState.updateCurrentPage(currentDrawing: currentDrawing, recordingURL: recordingURL, image: image)
            break

        case .nextPage(let currentDrawing, let recordingURL, let image):
            state.storyCreationState.moveToNextPage(currentDrawing: currentDrawing, recordingURL: recordingURL, image: image)

        case .previousPage(let currentDrawing, let recordingURL, let image):
            state.storyCreationState.moveToPreviousPage(currentDrawing: currentDrawing, recordingURL: recordingURL, image: image)

        case .cancelAndDeleteCurrentStory(let completion):
            state.storyCreationState.cancelAndDeleteCurrentStory(completion)

        case .finishStory(let name):
            Task { [state] in
                try! await state.storyCreationState.createStory(named: name)
            }
    }
}
