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

//MARK: - FileManageable
protocol FileManageable {
    func removeItem(at URL: URL) throws
    func fileExists(atPath path: String) -> Bool
}

extension FileManager: FileManageable {
    
}

//MARK: - StoryCreationAction
enum StoryCreationAction: CustomStringConvertible {
    case cancelAndDeleteCurrentStory(String, () -> Void)
    case deleteRecordingsAndTextForPage(Page)
    case deleteTextForCurrentPage
    case finishedHelp
    case finishStory(String, ((String) async -> Void)?)
    case generateTextForCurrentPage(Page, URL)
    case initialize(StoryCardViewModel, [Page])
    case modifiedTextForPage(Page, String, CGPoint)
    case nextPage(PKDrawing, URL?, UIImage?, [Sticker], PageText?)
    case preview(URL)
    case previousPage(PKDrawing, URL?, UIImage?, [Sticker], PageText?)
    case reset
    case showLoading
    case dismissLoading(DismissViewControllerHandler)
    case toggleMenu(Bool)
    case update(PKDrawing, URL?, UIImage?, [Sticker], PageText?)
    case updatePageTextPosition(PageText?, CGPoint)
    case updateStickerPosition(StickerDisplayable, CGPoint)
    case updateTextForPage(Page, URL, [TimedStrings?], CGPoint?)

    var description: String {
        var base = "StoryCreationAction "
        
        switch self {
            case .update(let drawing, let url, let image, let stickers, let text):
                base += "Update drawing: \(drawing.strokes) url: \(url?.path ?? "nil"), image: \(image?.description ?? "nil"), stickers: \(stickers.count), storyText: \(text?.text ?? "nil")"
                
            case .nextPage(let drawing, let url, let image, let stickers, let text):
                base += "nextPage drawing: \(drawing.strokes) url: \(url?.path ?? "nil"), image: \(image?.description ?? "nil"), stickers: \(stickers.count), storyText: \(text?.text ?? "nil")"
                
            case .previousPage(let drawing, let url, let image, let stickers, let text):
                base += "previousPage drawing: \(drawing.strokes) url: \(url?.path ?? "nil"), image: \(image?.description ?? "nil"), stickers: \(stickers.count), storyText: \(text?.text ?? "nil")"
                
            case .cancelAndDeleteCurrentStory(let name, _):
                base += "cancelAndDeleteCurrentStory named: \(name)"
                
            case .finishStory(let string, _):
                base += "finishStory name: \(string)"
                
            case .initialize(let storyCardViewModel, let pages):
                base += "Initialize viewModel: \(storyCardViewModel), number of pages: \(pages.count)"
                
            case .reset:
                base += "Reset"
            
            case .showLoading:
                base += "showLoading"
            
            case .dismissLoading(_):
                base += "dismissLoading"
                
            case .finishedHelp:
                base += "finishedHelp"
                
            case .generateTextForCurrentPage(let page, let url):
                base += "generateTextForCurrentPage: \(page.index) url: \(url)"
                
            case .updateTextForPage(let page, let url, let timedStrings, let position):
                base += "updateTextForPage Page: \(page.index), url: \(url.lastPathComponent), text: \(timedStrings)) position: \(String(describing: position))"
                
            case .modifiedTextForPage(let page, let newText, let position):
                base += "modifiedTextForPage page: \(page.index), text: \(newText), position: \(position)"
                
            case .deleteRecordingsAndTextForPage(let page):
                base += "deleteRecordingsAndTextForPage page: \(page.index)"
            
            case .updateStickerPosition(let sticker, let newPosition):
                base += "updateStickerPosition sticker: \(sticker) position: \(newPosition)"
            
            case .updatePageTextPosition(let text, let newPosition):
                base += "updatePageTextPosition text: \(text?.text ?? "nil") position: \(newPosition)"
            
            case .preview(let url):
                base += "preview url: \(url)"
            
            case .toggleMenu(let isOn):
                base += "toggleMenu: \(isOn ? "on" : "off")"
            
            case .deleteTextForCurrentPage:
                base += "deleteTextForCurrentPage"
        }

        return base
    }
}

//MARK: - StoryCreationState
struct StoryCreationState {

    //MARK: - CreationState
    enum CreationState: Equatable {
        case new
        case editing(String) // String is the currentName of the story
        
        static func ==(lhs: CreationState, rhs: CreationState) -> Bool {
            switch (lhs, rhs) {
                case (.new, .new):
                    return true
                case (.editing(let l), .editing(let r)):
                    return l == r
                default:
                    return false
            }
        }
    }

    //MARK: - Computed Properties
    var duration: TimeInterval {
        pages.reduce(0) {
            $0 + $1.duration
        }
    }

    var currentPage: Page {
        get {
            currentPagePublisher.value
        }
        set(newPage) {
            currentPagePublisher.value = newPage
        }
    }
    
    //MARK: - Injected Properties
    let router: RouteController
    
    let fileManager: FileManageable

    var isFirstStory: Bool
    
    var isShowingMenu = false
    
    var pages = [Page]()
    
    var currentPagePublisher = CurrentValueSubject<Page, Never>(Page(drawing: PKDrawing(),
                                                                     index: 0,
                                                                     recordingURLs: [],
                                                                     stickers: Set<Sticker>(),
                                                                     pageText: nil))
    
    var creationState = CreationState.new
    
    var currentViewModel: StoryCreationViewModel? = nil
    
    var currentName: String? {
        currentViewModel?.name
    }
    
    let dataStore: StoryDataStorable

    //MARK: - init
    init(router: RouteController = AppLifeCycleManager.shared.router,
         fileManager: FileManageable = FileManager.default,
         dataStore: StoryDataStorable) {
        self.isFirstStory = !UserDefaults.standard.bool(forKey: UserDefaultKeys.isNotFirstStory.rawValue)
        self.router = router
        self.fileManager = fileManager
        self.dataStore = dataStore
    }

    mutating func showDrawingView(numberOfStories: Int) {
        let vm = StoryCreationViewModel(store: AppLifeCycleManager.shared.store, name: "Story \(numberOfStories + 1)", isFirstStory: isFirstStory)
        router.route(to: .newStory(vm))
        currentViewModel = vm
    }

    mutating func showDrawingView(for viewModel: StoryCardViewModel, numberOfStories: Int) {
        let vm = StoryCreationViewModel(store: AppLifeCycleManager.shared.store, name: viewModel.title, isFirstStory: isFirstStory)
        switch viewModel.pages.first {
            case .none:
                pages = []
                currentPage = Page(drawing: PKDrawing(),
                                   index: 0,
                                   recordingURLs: OrderedSet<URL?>(),
                                   stickers: Set<Sticker>(),
                                   pageText: nil)
            
            case .some(let page):
                pages = viewModel.pages
                currentPage = page
                
        }
        
        router.route(to: .newStory(vm))
        currentViewModel = vm
    }

    func deleteTextAndRecordings(for page: Page) {
        page
            .recordingURLs
            .compactMap { $0 }
            .forEach {
                // Do I want to catch this error? What would I do? Try again?
                try? fileManager.removeItem(at: $0)
            }
    }

    func showTextAndRecordingDeleteConfirmation(page: Page) {
        let deleteAction = UIAlertAction(
            title: LonesomeDoveStrings.textAndRecordingDeleteConfirmationDelete.rawValue,
            style: .destructive) { _ in
                AppLifeCycleManager.shared.store?.dispatch(.storyCreation(.deleteRecordingsAndTextForPage(page)))
            }
        let cancelAction = UIAlertAction(title: LonesomeDoveStrings.textAndRecordingDeleteConfirmationCancel.rawValue, style: .cancel) { _ in
            // Do nothing right?
        }
        let viewModel = AlertViewModel(
            title:LonesomeDoveStrings.textAndRecordingDeleteConfirmationTitle.rawValue,
            message: LonesomeDoveStrings.textAndRecordingDeleteConfirmationMessage.rawValue,
            actions: [deleteAction, cancelAction])
        router.route(to: .alert(viewModel, nil))
    }

    mutating func updateCurrentPage(currentDrawing: PKDrawing, recordingURL: URL?, image: UIImage?, stickers: [Sticker], storyText: PageText?) {
        if currentPage.drawing != currentDrawing {
            currentPage.drawing = currentDrawing
        }
        
        currentPage.recordingURLs.append(recordingURL)
        currentPage.image = image
        stickers.forEach {
            currentPage.stickers.insert($0)
        }
        currentPage.text = storyText
        
        if pages.contains(currentPage) {
            pages[currentPage.index] = currentPage
        } else {
            pages.append(currentPage)
        }
    }

    mutating func moveToNextPage(currentDrawing: PKDrawing, recordingURL: URL?, image: UIImage?, stickers: [Sticker], storyText: PageText?) {
        updateCurrentPage(currentDrawing: currentDrawing, recordingURL: recordingURL, image: image, stickers: stickers, storyText: storyText)

        if currentPage.index + 1 >= pages.count {
            currentPage = Page(drawing: PKDrawing(),
                               index: currentPage.index + 1,
                               recordingURLs: [],
                               stickers: Set<Sticker>(),
                               pageText: PageText(text: "", type: .modified))
        } else {
            currentPage = pages[currentPage.index + 1]
        }
    }

    mutating func moveToPreviousPage(currentDrawing: PKDrawing, recordingURL: URL?, image: UIImage?, stickers: [Sticker], storyText: PageText?) {
        updateCurrentPage(currentDrawing: currentDrawing, recordingURL: recordingURL, image: image, stickers: stickers, storyText: storyText)

        let currentIndex = currentPage.index
        if currentPage.index > 0 {
            currentPage = pages[currentIndex - 1]
        }
    }

    func createStory(named name: String, pages: [Page]) async throws {
        let creator = StoryCreator()
//        let pages = await dataStore.fetchPages(storyName: name)
        try await creator.createStory(from: pages, named: name)
    }

    mutating func generateTextForCurrentPage(position: CGPoint) async {
        
        let speechRecognizer = SpeechRecognizer()//urls: currentPage.recordingURLs.compactMap { $0 })
        let urls = currentPage
            .recordingURLs
            .compactMap { $0 }
            
        for url in urls {
            if let timedString = await speechRecognizer.generateTimeStrings(for: url) {
                currentPage.update(text: timedString.formattedString, url: url, type: .generated, position: position)
            }
        }
    }

    func cancelAndDeleteCurrentStory(named: String, completion: () -> Void) {
        pages
            .map { $0.recordingURLs}
            .flatMap { $0 }
            .compactMap { $0 }
            .filter { fileManager.fileExists(atPath: $0.path) }
            .forEach { try? fileManager.removeItem(at: $0) }

        // TODO: Once we are saving drafts to the database we need to remove the draft as well
        dataStore.deleteDraft(named: named)

        completion()
    }
}

func storyCreationReducer(state: inout AppState, action: StoryCreationAction) {
    switch action {
        case .update(let currentDrawing, let recordingURL, let image, let stickers, let pageText):
            state.storyCreationState.updateCurrentPage(currentDrawing: currentDrawing, recordingURL: recordingURL, image: image, stickers: stickers, storyText: pageText)
            break

        case .nextPage(let currentDrawing, let recordingURL, let image, let stickers, let pageText):
            state.storyCreationState.moveToNextPage(currentDrawing: currentDrawing,
                                                    recordingURL: recordingURL,
                                                    image: image,
                                                    stickers: stickers,
                                                    storyText: pageText)
            state.dataStore.save()

        case .previousPage(let currentDrawing, let recordingURL, let image, let stickers, let pageText):
            state.storyCreationState.moveToPreviousPage(currentDrawing: currentDrawing,
                                                        recordingURL: recordingURL,
                                                        image: image,
                                                        stickers: stickers,
                                                        storyText: pageText)
            state.dataStore.save()

        case .cancelAndDeleteCurrentStory(let name, let completion):
            state.storyCreationState.cancelAndDeleteCurrentStory(named: name, completion: completion)

        case .finishStory(let name, let completion):
            state.dataStore.save()
            Task { [state] in
                try? await state.storyCreationState.createStory(named: name, pages: state.storyCreationState.pages)
                await completion?(name)
            }

        case .initialize(let viewModel, let pages):
            state.storyCreationState.pages = pages
            if let page = pages.first {
                state.storyCreationState.currentPage = page
            }
            state.storyCreationState.creationState = .editing(viewModel.title)

        case .reset:
            state.storyCreationState = StoryCreationState(dataStore: state.dataStore)
        
        case .toggleMenu(let isOn):
            state.storyCreationState.isShowingMenu = isOn
            AppLifeCycleManager.shared.router.route(to: .toggleStoryCreationMenu(isOn))

        case .finishedHelp:
            UserDefaults.standard.set(true, forKey: UserDefaultKeys.isNotFirstStory.rawValue)
            state.storyCreationState.isFirstStory = false

        case .generateTextForCurrentPage:
            break

        case .updateTextForPage(let page, let url, let timedStrings, let textPosition):
            if state.storyCreationState.currentPage.index == page.index {
                let text = timedStrings.compactMap { $0?.formattedString }.reduce(into: "", { $0 = $0 + " " + $1 })
                state.storyCreationState.currentPage.update(text: text, url: url, type: .generated, position: textPosition)
                state.storyCreationState.currentPagePublisher.send(state.storyCreationState.currentPage)
            }

        case .modifiedTextForPage(_, let newText, let textPosition):
            if newText.trimmingCharacters(in: .whitespaces).isEmpty {
                state.storyCreationState.showTextAndRecordingDeleteConfirmation(page: state.storyCreationState.currentPage)
            } else {
                state.storyCreationState.currentPage.update(text: newText, url: nil, type: .modified, position: textPosition)
                state.storyCreationState.currentPagePublisher.send(state.storyCreationState.currentPage)
            }

        case .deleteRecordingsAndTextForPage(let page):
            state.storyCreationState.deleteTextAndRecordings(for: page)
            if page.index == state.storyCreationState.currentPage.index {
                state.storyCreationState.currentPage.recordingURLs = OrderedSet<URL?>()
            }
        
        case .updateStickerPosition(let sticker, let position):
            guard let sticker = sticker as? Sticker,
                var stickerForUpdate = state
                .storyCreationState
                .currentPage
                .stickers
                .first(where: {
                    $0 == sticker
                })
            else { return }
            
            state.storyCreationState.currentPage.stickers.remove(stickerForUpdate)
            stickerForUpdate.position = position
            state.storyCreationState.currentPage.stickers.insert(stickerForUpdate)
            
        case .updatePageTextPosition(_, let newPoint):
            state.storyCreationState.currentPage.text?.position = newPoint
            
        case .preview(let url):
            AppLifeCycleManager.shared.router.route(to: .previewStory(url))
        
        case .showLoading:
            AppLifeCycleManager.shared.router.route(to: .loading)
        
        case .dismissLoading(let handler):
            AppLifeCycleManager.shared.router.route(to: .dismissPresentedViewController(handler))
        
        case .deleteTextForCurrentPage:
            state.storyCreationState.currentPage.text = PageText(text: "", type: .modified)
            state.storyCreationState.deleteTextAndRecordings(for: state.storyCreationState.currentPage)
    }
}
