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
    func currentImage() -> UIImage?
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

class StoryCreationViewModel: StoryCreationViewControllerDisplayable, Actionable, ObservableObject {

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

    var drawingPublisher: CurrentValueSubject<PKDrawing, Never>
    
    var recognizedTextPublisher: CurrentValueSubject<String, Never>

    var currentDrawing: PKDrawing

    @Published var stickers: [Sticker] = []

    var lastDrawingImage: UIImage? {
        guard let illustrationData = stickers.last?.stickerData,
              let drawing = try? PKDrawing(data: illustrationData)
        else { return nil }
        return drawing.image(from: drawing.bounds, scale: 1.0)
    }

    weak var store: AppStore?

    var recordingURL: URL?

    var name: String

   @Published private var potentialName: String = ""

    var cancellables = Set<AnyCancellable>()

    weak var delegate: StoryCreationViewModelDelegate?

    var timerViewModel: TimerViewModel

    @Published var storyNameViewModel: TextFieldViewModel

    var recordingStateCancellable: AnyCancellable?
    
    let isFirstStory: Bool

    init(store: AppStore? = nil,
         name: String,
         isFirstStory: Bool,
         timerViewModel: TimerViewModel = TimerViewModel()) {
        self.store = store
        self.name = name
        self.drawingPublisher = CurrentValueSubject<PKDrawing, Never>(store?.state.storyCreationState.currentPagePublisher.value.drawing ?? PKDrawing())
        self.recognizedTextPublisher = CurrentValueSubject<String, Never>(store?.state.storyCreationState.currentPage.text ?? "test test")
        self.currentDrawing = store?.state.storyCreationState.currentPage.drawing ?? PKDrawing()
        self.timerViewModel = timerViewModel
        self.storyNameViewModel = TextFieldViewModel(placeholder: name)
        self.isFirstStory = isFirstStory
        addSubscribers()
    }

    func didUpdate(drawing: PKDrawing) {
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
                                            tint: Color.funColor(for: .red),
                                            alternateImageTint: nil,
                                            actionable: self)

    lazy var doneButton = ButtonViewModel(title: "Done",
                                          description: "Save final story or a Draft to keep adding pages",
                                          systemImageName: "checkmark.square.fill",
                                          alternateSysteImageName: nil,
                                          actionTogglesImage: false,
                                          tint: Color.funColor(for: .green),
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
                                          systemImageName: "square.and.arrow.down.fill",
                                          alternateSysteImageName: nil,
                                          actionTogglesImage: false,
                                          tint: .white,
                                          alternateImageTint: nil,
                                          actionable: self)

    lazy var savedImageButton: ButtonViewModel =
        ButtonViewModel(title: "Saved Drawings Drawer",
                        description: "Saved drawings can be seen here",
                        systemImageName: nil,
                        alternateSysteImageName: nil,
                        actionTogglesImage: false,
                        tint: .white,
                        alternateImageTint: nil,
                        actionable: self,
                        image: lastDrawingImage)

    func trailingButtons() -> [ButtonViewModel] {
        lastDrawingImage == nil ? [saveButton, cancelButton, doneButton] : [savedImageButton, saveButton, cancelButton, doneButton]
    }

    func didPerformAction(type: ButtonViewModel.ActionType, for model: ButtonViewModel) {
        switch type {
            case .main where model == recordingButton:
                handleStartRecording()

            case .alternate where model == recordingButton:
                finishRecording()

            case _ where model == previousPageButton:
                finishRecording()
                store?.dispatch(.storyCreation(.previousPage(currentDrawing, recordingURL, delegate?.currentImage())))

            case _ where model == nextPageButton:
                finishRecording()
                store?.dispatch(.storyCreation(.nextPage(currentDrawing, recordingURL, delegate?.currentImage())))
                
        	case _ where model == doneButton:
                handleDoneButton()

        	case _ where model == cancelButton:
                AppLifeCycleManager.shared.router.route(to: .dismissPresentedViewController(nil))

            case _ where model == helpButton:
                delegate?.showHelpOverlay()

            case _ where model == saveButton:
                delegate?.animateSave()
                store?.dispatch(.storyCreation(.update(currentDrawing, nil, delegate?.currentImage())))
                store?.dispatch(.sticker(.save(drawingPublisher.value.dataRepresentation(), delegate?.currentImage()?.pngData() ?? Data(), Date())))
                store?.dispatch(.dataStore(.save))
                store?.dispatch(.sticker(.fetchStickers))

            case _ where model == savedImageButton:
                store?.dispatch(.sticker(.showStickerDrawer))

            default:
                break
        }
    }
    
    func didFinishHelp() {
        store?.dispatch(.storyCreation(.finishedHelp))
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
        let saveAsDraftAction = UIAlertAction(title: "Save as Draft", style: .default) { [weak self] _ in
            self?.saveAsDraft()
        }
        let createStoryAction = UIAlertAction(title: "Create Story", style: .default) { [weak self] _ in
            self?.createStory()
        }
        let alertViewModel = AlertViewModel(title: "Create Story",
                                            message: "Would you like to create your story or save as a draft? Saving as a draft will allow you to edit this Story later.",
                                            actions: [ saveAsDraftAction, createStoryAction])

        AppLifeCycleManager.shared.router.route(to: .alert(alertViewModel, nil))
    }

    func createStory() {
        do {
            try commonSave()
            store?.dispatch(.storyCreation(.finishStory(name)))
            let duration = store?.state.storyCreationState.pages.reduce(0) {$0 + $1.duration } ?? 0.0
            let storyURL = DataLocationModels.stories(name).URL()
            store?.dispatch(.dataStore(.addStory(name, storyURL, duration, store?.state.storyCreationState.pages.count ?? 0)))
            store?.dispatch(.dataStore(.save))
            store?.dispatch(.storyCreation(.reset))
            AppLifeCycleManager.shared.router.route(to: .dismissPresentedViewController({
                AppLifeCycleManager.shared.router.route(to: .dismissPresentedViewController({ [weak self] in
                    self?.store?.dispatch(.storyCard(.updateStoryList))
                }))
            }))
        } catch let error as SaveError {
            AppLifeCycleManager.shared.router.route(to: .warning(error.warning))
        } catch let error {
            fatalError("Errors thrown here should be of type SaveError. Error: \(error)")
        }
    }

    func saveAsDraft() {
        do {
            try commonSave()
            if let pages = store?.state.storyCreationState.pages {
                store?.dispatch(.dataStore(.addDraft(name, pages, stickers)))
                store?.dispatch(.dataStore(.save))
            }
            store?.dispatch(.storyCreation(.reset))
            AppLifeCycleManager.shared.router.route(to: .dismissPresentedViewController({
                AppLifeCycleManager.shared.router.route(to: .dismissPresentedViewController({ [weak self] in
                    self?.store?.dispatch(.storyCard(.updateStoryList))
                }))
            }))
        } catch let error as SaveError {
            AppLifeCycleManager.shared.router.route(to: .warning(error.warning))
        } catch let error {
            fatalError("Errors thrown here should be of type SaveError. Error: \(error)")
        }
    }

    /// Updates the current page and then checks conditions to see if saving should begin.
    ///
    /// - Throws: `SaveError.noPages` if there are not valid pages. `SaveError.uniqueName` if potentialName is the name of another Story.
    func commonSave() throws {
        finishRecording()
        if store?.state.storyCreationState.pages.count == 0 ||
            store?.state.storyCreationState.duration == 0 {
            throw SaveError.noPages
        } else if !verifyUnique(name: potentialName.isEmpty ? name : potentialName) {
            throw SaveError.uniqueName
        } else {
            name = potentialName.isEmpty ? name : potentialName
            AppLifeCycleManager.shared.router.route(to: .loading)
        }
    }

    func verifyUnique(name: String) -> Bool {
        store?.state.storyListState.storyCardViewModels.first(where: {
            $0.title == name
        }) == nil
    }

    func addSubscribers() {
        store?
            .state
            .storyCreationState
            .currentPagePublisher
//            .map {$0.drawing}
            .sink { [weak self] in
                self?.drawingPublisher.send($0.drawing)
                self?.recognizedTextPublisher.send($0.text)
                
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
                self?.stickers = drawings
                if let illustrationData = drawings.last?.stickerData,
                let drawing = try? PKDrawing(data: illustrationData) {
                    let image =  drawing.image(from: drawing.bounds, scale: 1.0)
                    self?.savedImageButton.image = image
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
        switch newState {
            case .started(let startTime):
                timerViewModel.startTime = Int(startTime)

        	case .timeUpdated(let newTime):
                timerViewModel.time += Int(newTime) - timerViewModel.startTime
                timerViewModel.startTime = Int(newTime)

            case .paused:
                recordingButton.currentImageName = recordingButton.systemImageName

        	default:
            	break
        }
    }
    
    func finishRecording() {
        store?.dispatch(.storyCreation(.update(currentDrawing, recordingURL, delegate?.currentImage())))
        store?.dispatch(.recording(.finishRecording))
        if let currentPage = store?.state.storyCreationState.currentPage {
            store?.dispatch(.storyCreation(.generateTextForCurrentPage(currentPage)))
        }
    }
}
