//
//  DrawingViewModel.swift
//  LonesomeDove
//  Created on 10/22/21.
//

import Combine
import Foundation
import Media
import os
import PencilKit
import SwiftUI
import SwiftUIFoundation

protocol StoryCreationViewModelDelegate: AnyObject {
    func currentImage(isSnapshot: Bool) -> UIImage?
    func showHelpOverlay()
    func animateSave()
}

class TimerViewModel: TimerDisplayable {
    @Published var time: Int = 0
    var startTime: Int = 0

    init(time: Int = 0) {
        self.time = time
    }
}

class StoryCreationViewModel: StoryCreationViewControllerDisplayable, Actionable, ObservableObject, MenuButtonProvider {

    enum SaveError: Error {
        case noPages
        case uniqueName

        var warning: Route.Warning {
            switch self {
                case .noPages:
                    return Route.Warning.noPages

                case .uniqueName:
                    return Route.Warning.uniqueName
            }
        }
    }
    
    enum State {
        case edited
        case initial
    }

    var currentPagePublisher: CurrentValueSubject<Page, Never>?
    
    var drawingPublisher: CurrentValueSubject<PKDrawing, Never>

    var recognizedTextPublisher: CurrentValueSubject<PageText?, Never>

    var currentDrawing: PKDrawing

    @Published var stickers: [Sticker] = []

    @Published private var potentialName: String = ""

    @Published var storyNameViewModel: TextFieldViewModel
    
    @Published var pageNumber: Int

    var lastDrawingImage: UIImage? {
        guard let illustrationData = stickers.last?.stickerData,
              let drawing = try? PKDrawing(data: illustrationData)
        else {
            return UIImage(named: "placeholder")
        }
       let image = drawing.image(from: drawing.bounds, scale: 1.0)
        return image
    }

    weak var store: AppStore?

    var recordingURL: URL?

    var name: String

    var cancellables = Set<AnyCancellable>()

    weak var delegate: StoryCreationViewModelDelegate?

    var timerViewModel: TimerViewModel?

    var recordingStateCancellable: AnyCancellable?

    let isFirstStory: Bool
    
    var state: State = .initial

    init(store: AppStore? = nil,
         name: String,
         isFirstStory: Bool,
         timerViewModel: TimerViewModel? = nil) {
        self.store = store
        self.name = name
        self.currentPagePublisher = store?.state.storyCreationState.currentPagePublisher
        self.drawingPublisher = CurrentValueSubject<PKDrawing, Never>(store?.state.storyCreationState.currentPagePublisher.value.drawing ?? PKDrawing())
        self.recognizedTextPublisher = CurrentValueSubject<PageText?, Never>(store?.state.storyCreationState.currentPage.text)
        self.currentDrawing = store?.state.storyCreationState.currentPage.drawing ?? PKDrawing()
        self.timerViewModel = timerViewModel
        self.storyNameViewModel = TextFieldViewModel(placeholder: name)
        self.isFirstStory = isFirstStory
        self.pageNumber = store?.state.storyCreationState.currentPage.index ?? 0
        self.menuButtons = []
        self.menuButtons = [savedImageButton, saveButton, previewStoryButton]
        addSubscribers()
    }

    func didUpdate(drawing: PKDrawing) {
        state = .edited
        currentDrawing = drawing
    }

    lazy var previousPageButton = ButtonViewModel(title: "Previous Page",
                                                  description: "Previous page",
                                                  systemImageName: "backward.end.fill",
                                                  alternateSysteImageName: nil,
                                                  actionTogglesImage: false,
                                                  tint: .white,
                                                  alternateImageTint: nil,
                                                  actionable: self)

    lazy var recordingButton = ButtonViewModel(title: "Record",
                                               description: "Start/Stop recording",
                                               systemImageName: "record.circle",
                                               alternateSysteImageName: "pause.circle.fill",
                                               actionTogglesImage: true,
                                               tint: .red,
                                               alternateImageTint: .red,
                                               actionable: self)

    lazy var nextPageButton = ButtonViewModel(title: "Next Page",
                                              description: "Next page",
                                              systemImageName: "forward.end.fill",
                                              alternateSysteImageName: nil,
                                              actionTogglesImage: false,
                                              tint: .white,
                                              alternateImageTint: nil,
                                              actionable: self)

    func leadingButtons() -> [ButtonViewModel] {
        [previousPageButton, recordingButton, nextPageButton]
    }

    lazy var cancelButton = ButtonViewModel(title: "Cancel",
                                            description: "Dismiss without saving",
                                            systemImageName: "x.square.fill",
                                            alternateSysteImageName: nil,
                                            actionTogglesImage: false,
                                            tint: .white,
                                            alternateImageTint: nil,
                                            actionable: self)

    lazy var doneButton = ButtonViewModel(title: "Done",
                                          description: "Save final story or a Draft to keep adding pages",
                                          systemImageName: "square.and.arrow.down.fill",
                                          alternateSysteImageName: nil,
                                          actionTogglesImage: false,
                                          tint: .white,
                                          alternateImageTint: nil,
                                          actionable: self)

    lazy var helpButton = ButtonViewModel(title: "Help",
                                          description: "Shows the help screen",
                                          systemImageName: "questionmark.square.fill",
                                          alternateSysteImageName: nil,
                                          actionTogglesImage: false,
                                          tint: .white,
                                          alternateImageTint: nil,
                                          actionable: self)

    lazy var saveButton = ButtonViewModel(title: "Save Drawing",
                                          description: "Save the drawing for reuse later",
                                          systemImageName: "photo.fill.on.rectangle.fill",
                                          alternateSysteImageName: nil,
                                          actionTogglesImage: false,
                                          tint: .white,
                                          alternateImageTint: nil,
                                          actionable: self,
                                          buttonType: .menu)

    lazy var savedImageButton: ButtonViewModel =
        ButtonViewModel(title: "Saved Drawings Drawer",
                        description: "Saved drawings can be seen here",
                        systemImageName: nil,
                        alternateSysteImageName: nil,
                        actionTogglesImage: false,
                        tint: .white,
                        alternateImageTint: nil,
                        actionable: self,
                        image: lastDrawingImage,
                        buttonType: .menu)
    
    lazy var previewStoryButton: ButtonViewModel = ButtonViewModel(title: "Preview Story",
                                                                   description: "Preview what your final story will look like",
                                                                   systemImageName: "play.rectangle.fill",
                                                                   alternateSysteImageName: nil,
                                                                   actionTogglesImage: false,
                                                                   tint: .white,
                                                                   alternateImageTint: nil,
                                                                   actionable: self,
                                                                   image: nil,
                                                                   buttonType: .menu)
    
    lazy var menuButton: ButtonViewModel = ButtonViewModel(title: "Action Menu",
                                                           description: "Additional actions are located here",
                                                           systemImageName: "line.3.horizontal.circle.fill",
                                                           actionTogglesImage: false,
                                                           tint: .white,
                                                           actionable: self,
                                                           image: nil,
                                                           buttonType: .normal)

    func trailingButtons() -> [ButtonViewModel] {
        [doneButton, cancelButton, menuButton]
    }
    
    @Published var menuButtons: [ButtonViewModel]

    func didPerformAction(type: ButtonViewModel.ActionType, for model: ButtonViewModel) {
        switch type {
            case .main where model == recordingButton:
                handleStartRecording()

            case .alternate where model == recordingButton:
                finishRecording()

            case _ where model == previousPageButton:
                state = .initial
                finishRecording()
                store?.dispatch(
                    .storyCreation(
                        .previousPage(currentDrawing, recordingURL, delegate?.currentImage(isSnapshot: false), Array(store?.state.storyCreationState.currentPage.stickers ?? Set<Sticker>()), store?.state.storyCreationState.currentPage.text)
                    )
                )

            case _ where model == nextPageButton:
                state = .initial
                finishRecording()
                store?.dispatch(
                    .storyCreation(
                        .nextPage(currentDrawing, recordingURL, delegate?.currentImage(isSnapshot: false), Array(store?.state.storyCreationState.currentPage.stickers ?? Set<Sticker>()), store?.state.storyCreationState.currentPage.text)
                                              )
                )

        	case _ where model == doneButton:
                handleDoneButton()

        	case _ where model == cancelButton:
                store?.dispatch(.storyCreation(.reset))
                AppLifeCycleManager.shared.router.route(to: .dismissPresentedViewController(nil))

            case _ where model == helpButton:
                delegate?.showHelpOverlay()

            case _ where model == saveButton:
                store?.dispatch(.storyCreation(.toggleMenu(false)))
                delegate?.animateSave()
                store?.dispatch(
                    .storyCreation(
                        .update(currentDrawing, nil, delegate?.currentImage(isSnapshot: true), Array(store?.state.storyCreationState.currentPage.stickers ?? Set<Sticker>()), store?.state.storyCreationState.currentPage.text)
                                              )
                )
                store?.dispatch(.sticker(.save(drawingPublisher.value.dataRepresentation(), delegate?.currentImage(isSnapshot: true)?.pngData() ?? Data(), Date(), UUID())))
                store?.dispatch(.dataStore(.save))
                store?.dispatch(.sticker(.fetchStickers))
                DispatchQueue.main.async {
                    self.menuButtons += [self.savedImageButton]
                }
                

            case _ where model == savedImageButton:
                store?.dispatch(.storyCreation(.toggleMenu(false)))
                store?.dispatch(.sticker(.showStickerDrawer))
            
            case _ where model == previewStoryButton:
                store?.dispatch(.storyCreation(.toggleMenu(false)))
                previewStory()
            
            case _ where model == menuButton:
                if let store = store {
                    store.dispatch(.storyCreation(.toggleMenu(store.state.storyCreationState.isShowingMenu ? false : true)))
                }
                
            default:
                fatalError("Failed to handle a button case for \(model.self)")
        }
    }

    func didFinishHelp() {
        store?.dispatch(.storyCreation(.finishedHelp))
    }

    func textDidEndEditing(text: String, position: CGPoint) {
        guard let store = store else {
            return
        }

        store.dispatch(.storyCreation(.modifiedTextForPage(store.state.storyCreationState.currentPage, text, position)))
    }
    
    func update(sticker: StickerDisplayable, position: CGPoint) {
        store?.dispatch(.storyCreation(.updateStickerPosition(sticker, position)))
    }
    
    func update(text: PageText?, position: CGPoint) {
        store?.dispatch(.storyCreation(.updatePageTextPosition(text, position)))
    }
    
    func cleanupPreviews() {
        let previews = DataLocationModels.stories("").containingDirectory()
        let allStories = try? FileManager.default.contentsOfDirectory(atPath: previews.path)
        allStories?
            .map { URL(fileURLWithPath: $0) }
            .filter { $0.lastPathComponent.contains("preview-") }
            .forEach {
                try? FileManager.default.removeItem(at: $0)
            }
            
    }
    
    func deleteTextForCurrentPage() {
        let deleteAction = UIAlertAction(title: "Yes, delete", style: .destructive) { [weak self] action in
            self?.store?.dispatch(.storyCreation(.deleteTextForCurrentPage))
        }
        let cancel = UIAlertAction(title: "No! Keep!", style: .cancel) { _ in }
        let alertViewModel = AlertViewModel(title: "Are you sure?", message: "Do you want to delete this text? Deleting this text will also delte all associated recordings.", actions: [deleteAction, cancel])
        AppLifeCycleManager.shared.router.route(to: .alert(alertViewModel, nil))
    }
}

// MARK: - Private
private extension StoryCreationViewModel {

    func handleStartRecording() {
        if recordingURL == nil {
            recordingURL = DataLocationModels.recordings(UUID()).URL()
            AppLifeCycleManager.shared.logger.log("recordingURL: \(self.recordingURL!)")
        }
        store?.dispatch(.recording(.startOrResumeRecording(recordingURL)))
        addStateObserverIfNeeded()
    }

    func handleDoneButton() {
        guard let store = store else {
             return
        }
        
        let saveAsDraftAction = UIAlertAction(title: store.state.storyCreationState.creationState == .new ? LonesomeDoveStrings.saveAsDraftActionTitle.rawValue : LonesomeDoveStrings.updateDraftActionTitle.rawValue,
                                              style: .default) { [weak self] _ in
            self?.saveAsDraft()
        }
        let createStoryAction = UIAlertAction(title: LonesomeDoveStrings.createStoryActionTitle.rawValue,
                                              style: .default) { [weak self] _ in
            self?.createStory()
        }
        let cancelAction = UIAlertAction(title: LonesomeDoveStrings.createStoryCancelTitle.rawValue, style: .cancel)
        let alertViewModel = AlertViewModel(title: LonesomeDoveStrings.createStoryAlertTitle.rawValue,
                                            message: LonesomeDoveStrings.createStoryAlertMessage.rawValue,
                                            actions: [cancelAction, saveAsDraftAction, createStoryAction])

        AppLifeCycleManager.shared.router.route(to: .alert(alertViewModel, nil))
    }
    
    func createStory() {
        
        let creationCompletion: (String) async -> Void = {[weak self] name in
            await MainActor.run { [weak self] in
                self?.store?.dispatch(.storyCreation(.dismissLoading({ [weak self] in
                    let duration = self?.store?.state.storyCreationState.pages.reduce(0) {$0 + $1.duration } ?? 0.0
                    let storyURL = DataLocationModels.stories(name).URL()
                    self?.store?.dispatch(
                        .dataStore(
                            .addStory(name, storyURL, duration, self?.store?.state.storyCreationState.pages.count ?? 0, self?.store?.state.storyCreationState.currentPage.image?.pngData())
                        )
                    )
                    self?.store?.dispatch(.dataStore(.save))
                    self?.store?.dispatch(.storyCreation(.reset))
                    AppLifeCycleManager.shared.router.route(to: .dismissPresentedViewController({ [weak self] in
                        self?.store?.dispatch(.storyCard(.updateStoryList))
                    }))
                })))
            }
        }
        
        commonSave()
        store?.dispatch(.storyCreation(.finishStory(name, creationCompletion)))
        store?.dispatch(.storyCreation(.showLoading))
        
        
    }
    
    func saveAsDraft() {
        commonSave()
        if let pages = store?.state.storyCreationState.pages {
            store?.dispatch(.dataStore(.addDraft(name, pages, Array(currentPagePublisher?.value.stickers ?? []))))
            store?.dispatch(.dataStore(.save))
        }
        store?.dispatch(.storyCreation(.reset))
        AppLifeCycleManager.shared.router.route(to: .dismissPresentedViewController({ [weak self] in
            self?.store?.dispatch(.storyCard(.updateStoryList))
        }))
    }
    
    /// Updates the current page and then checks conditions to see if saving should begin.
    func commonSave() {
        do {
            finishRecording()
            if store?.state.storyCreationState.pages.count == 0 ||
                store?.state.storyCreationState.duration == 0 {
                throw SaveError.noPages
            } else if !verifyUnique(name: potentialName.isEmpty ? name : potentialName) {
                throw SaveError.uniqueName
            } else {
                name = potentialName.isEmpty ? name : potentialName
            }
        } catch let error as SaveError {
            AppLifeCycleManager.shared.router.route(to: .warning(error.warning))
        } catch let error {
            fatalError("Errors thrown here should be of type SaveError. Error: \(error)")
        }
    }

    func verifyUnique(name: String) -> Bool {
        guard let store = store else { return false }
        
        switch store.state.storyCreationState.creationState {
            case .editing(let n):
                if n == name {
                    return true
                } else {
                    fallthrough
                }
            case .new:
                return store.state.storyListState.storyCardViewModels.first(where: {
                    $0.title == name
                }) == nil
        }
    }

    func addSubscribers() {
        store?
            .state
            .storyCreationState
            .currentPagePublisher
            .sink { [weak self] in
                guard let self = self else { return }
                
                switch self.state {
                    case .initial:
                        self.drawingPublisher.send($0.drawing)
                        
                    case .edited:
                        self.drawingPublisher.send(self.currentDrawing)
                }
                
                self.recognizedTextPublisher.send($0.text)
                self.pageNumber = $0.index
            }
            .store(in: &cancellables)

        storyNameViewModel.$text
            .debounce(for: 0.1, scheduler: DispatchQueue.main, options: .none)
            .replaceEmpty(with: self.name)
            .assign(to: \.potentialName, onWeak: self)
            .store(in: &cancellables)

        store?
            .state
            .stickerState
            .stickers
            .sink(receiveValue: { [weak self] drawings in
                guard let self = self else { return }
                self.stickers = drawings
                if let illustrationData = drawings.last?.stickerData,
                let drawing = try? PKDrawing(data: illustrationData) {
                    let image =  drawing.image(from: drawing.bounds, scale: 1.0)
                    self.savedImageButton.image = image
                    self.menuButtons = [self.savedImageButton, self.saveButton, self.previewStoryButton]
                    
                }
            })
            .store(in: &cancellables)
    }

    func addStateObserverIfNeeded() {
        guard recordingStateCancellable == nil else { return }

        recordingStateCancellable = store?
            .state
            .mediaState
            .recorder?
            .statePublisher
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                    case .failure(let error):
                        self?.store?.dispatch(.failure(error))

                    case .finished:
                        self?.finishRecording()
                        self?.recordingStateCancellable = nil
                        self?.recordingURL = nil
                        self?.recordingButton.currentImageName = self?.recordingButton.systemImageName

                }

            }, receiveValue: { [weak self] newState in
                self?.recordingControllerMoved(to: newState)
            })
    }

    func recordingControllerMoved(to newState: RecordingController.State) {
        guard let timerViewModel = timerViewModel else { return }
        
        switch newState {
            case .started(let startTime):
                timerViewModel.startTime = Int(startTime)

        	case .timeUpdated(let newTime):
                timerViewModel.time += Int(newTime) - timerViewModel.startTime
                timerViewModel.startTime = Int(newTime)

            case .paused:
                recordingButton.currentImageName = recordingButton.systemImageName
            
            case .interrupted:
                finishRecording()
                recordingStateCancellable = nil
                recordingURL = nil
                recordingButton.currentImageName = recordingButton.systemImageName

        	default:
            	break
        }
    }

    func finishRecording() {
        store?.dispatch(
            .storyCreation(
                .update(currentDrawing, recordingURL, delegate?.currentImage(isSnapshot: false), Array(store?.state.storyCreationState.currentPage.stickers ?? Set<Sticker>()), store?.state.storyCreationState.currentPage.text)
            )
        )
        store?.dispatch(.recording(.finishRecording))
        if let currentPage = store?.state.storyCreationState.currentPage {
            store?.dispatch(.storyCreation(.generateTextForCurrentPage(currentPage)))
        }
    }
    
    func previewStory() {
        let creationCompletion: (String) async -> Void = {[weak self] name in
            await MainActor.run { [weak self] in
                self?.store?.dispatch(.storyCreation(.dismissLoading({ [weak self] in
                    let storyURL = DataLocationModels.stories(name).URL()
                    self?.store?.dispatch(.storyCreation(.preview(storyURL)))
                })))
            }
        }
        
        commonSave()
        let previewName = "preview-" + name
        store?.dispatch(.storyCreation(.finishStory(previewName, creationCompletion)))
        store?.dispatch(.storyCreation(.showLoading))
    }
}
