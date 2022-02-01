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
    case initialize(StoryCardViewModel, [Page])
}

struct StoryCreationState {

    enum CreationState {
        case new
        case editing(String) // String is the currentName of the story
    }

    var creationState = CreationState.new

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

    func showDrawingView(numberOfStories: Int) {
        AppLifeCycleManager.shared.router.route(to: .newStory(StoryCreationViewModel(store: AppLifeCycleManager.shared.store, name: "Story \(numberOfStories + 1)")))
    }

    func showDrawingView(for viewModel: StoryCardViewModel, numberOfStories: Int) {
        AppLifeCycleManager.shared.router.route(to: .newStory(StoryCreationViewModel(store: AppLifeCycleManager.shared.store, name: viewModel.title, timerViewModel: TimerViewModel(time: Int(viewModel.duration)))))

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

        case .initialize(let viewModel, let pages):
            state.storyCreationState.pages = pages
            if let page = pages.first {
                state.storyCreationState.currentPage = page
            }
            state.storyCreationState.creationState = .editing(viewModel.title)
    }
}
