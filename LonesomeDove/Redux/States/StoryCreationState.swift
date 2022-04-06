//
//  StoryCreationState.swift
//  LonesomeDove
//  Created on 12/22/21.
//

import Collections
import Combine
import Foundation
import Media
import PencilKit

enum StoryCreationAction: CustomStringConvertible {
    case update(PKDrawing, URL?, UIImage?)
    case nextPage(PKDrawing, URL?, UIImage?)
    case previousPage(PKDrawing, URL?, UIImage?)
    case cancelAndDeleteCurrentStory(() -> Void)
    case finishStory(String)
    case initialize(StoryCardViewModel, [Page])
    case reset
    case finishedHelp
    case generateTextForCurrentPage(Page)
    case updateTextForPage(Page, [TimedStrings?], CGPoint?)
    case modifiedTextForPage(Page, String, CGPoint)
    case deleteRecordingsAndTextForPage(Page)

    var description: String {
        var base = "StoryCreationAction "
        
        switch self {
            case .update(let drawing, let url, let image):
                base += "Update drawing: \(drawing.strokes) url: \(url?.path ?? "nil"), image: \(image?.description ?? "nil")"
                
            case .nextPage(let drawing, let url, let image):
                base += "nextPage drawing: \(drawing.strokes) url: \(url?.path ?? "nil"), image: \(image?.description ?? "nil")"
                
            case .previousPage(let drawing, let url, let image):
                base += "previousPage drawing: \(drawing.strokes) url: \(url?.path ?? "nil"), image: \(image?.description ?? "nil")"
                
            case .cancelAndDeleteCurrentStory:
                base += "cancelAndDeleteCurrentStory"
                
            case .finishStory(let string):
                base += "finishStory name: \(string)"
                
            case .initialize(let storyCardViewModel, let pages):
                base += "Initialize viewModel: \(storyCardViewModel), number of pages: \(pages.count)"
                
            case .reset:
                base += "Reset"
                
            case .finishedHelp:
                base += "finishedHelp"
                
            case .generateTextForCurrentPage(let page):
                base += "generateTextForCurrentPage: \(page.index)"
                
            case .updateTextForPage(let page, let timedStrings, let position):
                base += "updateTextForPage Page: \(page.index), text: \(timedStrings)) position: \(String(describing: position))"
                
            case .modifiedTextForPage(let page, let newText, let position):
                base += "modifiedTextForPage page: \(page.index), text: \(newText), position: \(position)"
                
            case .deleteRecordingsAndTextForPage(let page):
                base += "deleteRecordingsAndTextForPage page: \(page.index)"
        }

        return base
    }
}

struct StoryCreationState {

    enum CreationState {
        case new
        case editing(String) // String is the currentName of the story
    }

    var creationState = CreationState.new

    var pages = [Page]()

    var duration: TimeInterval {
        pages.reduce(0) {
            $0 + $1.duration
        }
    }

    var currentPagePublisher = CurrentValueSubject<Page, Never>(Page(drawing: PKDrawing(),
                                                                     index: 0,
                                                                     recordingURLs: [],
                                                                     stickers: Set<Sticker>(),
                                                                     pageText: nil))

    var currentPage: Page {
        get {
            currentPagePublisher.value
        }
        set(newPage) {
            currentPagePublisher.value = newPage
        }
    }

    var isFirstStory: Bool

    init() {
        self.isFirstStory = !UserDefaults.standard.bool(forKey: UserDefaultKeys.isNotFirstStory.rawValue)
    }

    func showDrawingView(numberOfStories: Int) {
        AppLifeCycleManager.shared.router.route(to: .newStory(StoryCreationViewModel(store: AppLifeCycleManager.shared.store, name: "Story \(numberOfStories + 1)", isFirstStory: isFirstStory)))
    }

    func showDrawingView(for viewModel: StoryCardViewModel, numberOfStories: Int) {
        AppLifeCycleManager.shared.router.route(to: .newStory(StoryCreationViewModel(store: AppLifeCycleManager.shared.store, name: viewModel.title, isFirstStory: isFirstStory, timerViewModel: TimerViewModel(time: Int(viewModel.duration)))))

    }

    func deleteTextAndRecordings(for page: Page) {
        page
            .recordingURLs
            .compactMap { $0 }
            .forEach {
                // Do I want to catch this error? What would I do? Try again?
                try? FileManager.default.removeItem(at: $0)
            }
    }

    func showTextAndRecordingDeleteConfirmation(page: Page) {
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            AppLifeCycleManager.shared.store?.dispatch(.storyCreation(.deleteRecordingsAndTextForPage(page)))
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Do nothing right?
        }
        let viewModel = AlertViewModel(title: "Are you sure you want to delete this text?", message: "Deleting this text will also delete the recorded audio.", actions: [deleteAction, cancelAction])
        AppLifeCycleManager.shared.router.route(to: .alert(viewModel, nil))
    }

    mutating func updateCurrentPage(currentDrawing: PKDrawing, recordingURL: URL?, image: UIImage?) {
        if currentPage.drawing != currentDrawing {
            currentPage.drawing = currentDrawing
        }

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
            currentPage = Page(drawing: PKDrawing(),
                               index: currentPage.index + 1,
                               recordingURLs: [],
                               stickers: Set<Sticker>(),
                               pageText: nil)
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
        let creator = StoryCreator()
        try await creator.createStory(from: pages, named: name)
    }

    mutating func generateTextForCurrentPage(position: CGPoint) async {
        let generatedText = await currentPage.recordingURLs
            .compactMap { $0 }
            .asyncMap({ (url) -> TimedStrings? in
                let speechRecognizer = SpeechRecognizer(url: url)
                return await speechRecognizer.generateTimedStrings()
            })
            .compactMap { $0 }
            .reduce("") { $0 + " " + $1.formattedString }
        
        currentPage.update(text: generatedText, type: .generated, position: position)
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
                try? await state.storyCreationState.createStory(named: name)
            }

        case .initialize(let viewModel, let pages):
            state.storyCreationState.pages = pages
            if let page = pages.first {
                state.storyCreationState.currentPage = page
            }
            state.storyCreationState.creationState = .editing(viewModel.title)

        case .reset:
            state.storyCreationState = StoryCreationState()

        case .finishedHelp:
            UserDefaults.standard.set(true, forKey: UserDefaultKeys.isNotFirstStory.rawValue)
            state.storyCreationState.isFirstStory = false

        case .generateTextForCurrentPage:
            break

        case .updateTextForPage(let page, let timedStrings, let textPosition):
            if state.storyCreationState.currentPage.index == page.index {
                let text = timedStrings.compactMap { $0?.formattedString }.reduce(into: "", { $0 = $0 + " " + $1 })
//                state.storyCreationState.currentPage.generatedText = text
                state.storyCreationState.currentPage.update(text: text, type: .generated, position: textPosition)
                state.storyCreationState.currentPagePublisher.send(state.storyCreationState.currentPage)
            }

        case .modifiedTextForPage(_, let newText, let textPosition):
            if newText.trimmingCharacters(in: .whitespaces).isEmpty {
                state.storyCreationState.showTextAndRecordingDeleteConfirmation(page: state.storyCreationState.currentPage)
            } else {
//                state.storyCreationState.currentPage.text = newText
                state.storyCreationState.currentPage.update(text: newText, type: .modified, position: textPosition)
                state.storyCreationState.currentPagePublisher.send(state.storyCreationState.currentPage)
            }

        case .deleteRecordingsAndTextForPage(let page):
            state.storyCreationState.deleteTextAndRecordings(for: page)
            if page.index == state.storyCreationState.currentPage.index {
                state.storyCreationState.currentPage.recordingURLs = OrderedSet<URL?>()
            }
    }
}
