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
import SwiftUIFoundation


extension FileManager {
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

protocol StoryCreationViewModelDelegate: AnyObject {
    func currentImage() -> UIImage?
}

class TimerViewModel: TimerDisplayable {
    @Published var time: Int = 0
    var startTime: Int = 0

    init(time: Int = 0) {
        self.time = time
    }
}

class StoryCreationViewModel: StoryCreationViewControllerDisplayable, Actionable {
    
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

    var currentDrawing: PKDrawing

    var store: AppStore?

    var recordingURL: URL?

    var name: String
    
    private var potentialName: String = ""

    var cancellables = Set<AnyCancellable>()

    weak var delegate: StoryCreationViewModelDelegate?

    var timerViewModel: TimerViewModel
    
    var storyNameViewModel: TextFieldViewModel

    var recordingStateCancellable: AnyCancellable?

    init(store: AppStore? = nil,
         name: String,
         timerViewModel: TimerViewModel = TimerViewModel()) {
        self.store = store
        self.name = name
        self.drawingPublisher = CurrentValueSubject<PKDrawing, Never>(store?.state.storyCreationState.currentPagePublisher.value.drawing ?? PKDrawing())
        self.currentDrawing = store?.state.storyCreationState.currentPage.drawing ?? PKDrawing()
        self.timerViewModel = timerViewModel
        self.storyNameViewModel = TextFieldViewModel(placeholder: name)
        addSubscribers()
    }

    func didUpdate(drawing: PKDrawing) {
        currentDrawing = drawing
    }

    lazy var previousPageButton = ButtonViewModel(title: "Previous Page", systemImageName: "backward.end.fill", alternateSysteImageName: nil, actionTogglesImage: false, tint: .white, alternateImageTint: nil, actionable: self)
    lazy var recordingButton = ButtonViewModel(title: "Record", systemImageName: "record.circle", alternateSysteImageName: "pause.circle.fill", actionTogglesImage: true, tint: .red, alternateImageTint: .white, actionable: self)
    lazy var nextPageButton = ButtonViewModel(title: "Next Page", systemImageName: "forward.end.fill", alternateSysteImageName: nil, actionTogglesImage: false, tint: .white, alternateImageTint: nil, actionable: self)

    func leadingButtons() -> [ButtonViewModel] {
        [previousPageButton, recordingButton, nextPageButton]
    }

    lazy var cancelButton = ButtonViewModel(title: "Cancel", systemImageName: "x.square.fill", alternateSysteImageName: nil, actionTogglesImage: false, tint: .white, alternateImageTint: nil, actionable: self)
    lazy var doneButton = ButtonViewModel(title: "Done", systemImageName: "checkmark.square.fill", alternateSysteImageName: nil, actionTogglesImage: false, tint: .white, alternateImageTint: nil, actionable: self)

    func trailingButtons() -> [ButtonViewModel] {
        [cancelButton, doneButton]
    }

    func didPerformAction(type: ButtonViewModel.ActionType, for model: ButtonViewModel) {
        switch type {
            case .main where model == recordingButton:
                handleStartRecording()

            case .alternate where model == recordingButton:
                store?.dispatch(.recording(.pauseRecording))

            case _ where model == previousPageButton:
            	store?.dispatch(.storyCreation(.previousPage(currentDrawing, recordingURL, delegate?.currentImage())))
                store?.dispatch(.recording(.finishRecording))

            case _ where model == nextPageButton:
            	store?.dispatch(.storyCreation(.nextPage(currentDrawing, recordingURL, delegate?.currentImage())))
                store?.dispatch(.recording(.finishRecording))

        	case _ where model == doneButton:
                handleDoneButton()

        	case _ where model == cancelButton:
                AppLifeCycleManager.shared.router.route(to: .dismissPresentedViewController(nil))

            default:
                break
        }
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
                store?.dispatch(.dataStore(.addDraft(name, pages)))
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
        store?.dispatch(.storyCreation(.update(currentDrawing, recordingURL, delegate?.currentImage())))
        store?.dispatch(.recording(.finishRecording))
        
        if store?.state.storyCreationState.pages.count == 0 ||
            store?.state.storyCreationState.duration == 0 {
            throw SaveError.noPages
        } else if !verifyUnique(name: potentialName) {
            throw SaveError.uniqueName
        } else {
            name = potentialName
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
            .map {$0.drawing}
            .sink { [weak self] in
                self?.drawingPublisher.send($0)
            }
            .store(in: &cancellables)
        
        storyNameViewModel.$text
            .debounce(for: 0.1, scheduler: DispatchQueue.main, options: .none)
            .replaceEmpty(with: self.name)
            .assign(to: \.potentialName, onWeak: self)
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
                        self?.store?.dispatch(.recording(.finishRecording))
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
}
