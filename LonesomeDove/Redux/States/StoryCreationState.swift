//
//  StoryCreationState.swift
//  LonesomeDove
//  Created on 12/22/21.
//

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
    case updateTextForPage(Page, [TimedStrings?])
    
    var description: String {
        var base = "StoryCreationAction "
        
        switch self {
        case .update(let drawing, let url, let image):
            base += "Update drawing: \(drawing.strokes) url: \(url?.path ?? "nil"), image: \(image?.description ?? "nil")"
            
        case .nextPage(let drawing, let url, let image):
            base += "Next Page drawing: \(drawing.strokes) url: \(url?.path ?? "nil"), image: \(image?.description ?? "nil")"
            
        case .previousPage(let drawing, let url, let image):
            base += "Previous Page drawing: \(drawing.strokes) url: \(url?.path ?? "nil"), image: \(image?.description ?? "nil")"
            
        case .cancelAndDeleteCurrentStory(_):
            base += "Cancel and Delete Current Story"
            
        case .finishStory(let string):
            base += "Finish Story name: \(string)"
            
        case .initialize(let storyCardViewModel, let pages):
            base += "Initialize viewModel: \(storyCardViewModel), number of pages: \(pages.count)"
            
        case .reset:
            base += "Reset"
            
        case .finishedHelp:
            base += "Finished Help"
            
        case .generateTextForCurrentPage(let page):
            base += "Generate Text for Current Page: \(page.index)"
            
        case .updateTextForPage(let page, let timedStrings):
            base += "Update text for Page: \(page.index), text: \(timedStrings))"
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

    var currentPagePublisher = CurrentValueSubject<Page, Never>(Page(drawing: PKDrawing(), index: 0, recordingURLs: [], stickers: Set<Sticker>()))

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
            currentPage = Page(drawing: PKDrawing(), index: currentPage.index + 1, recordingURLs: [], stickers: Set<Sticker>())
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
    
    mutating func generateTextForCurrentPage() async {
        currentPage.text = await currentPage.recordingURLs
            .compactMap{ $0 }
            .asyncMap({ (url) -> TimedStrings? in
                let speechRecognizer = SpeechRecognizer(url: url)
                return await speechRecognizer.generateTimedStrings()
            })
            .compactMap { $0 }
            .reduce("") { $0 + " " + $1.formattedString }
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
        
        case .updateTextForPage(var page, let timedStrings):
            let text = timedStrings.compactMap { $0?.formattedString }.reduce(into: "", { $0 = $0 + " " + $1 })
            page.update(text: text)
    }
}
