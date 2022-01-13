//
//  DrawingViewModel.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/22/21.
//

import Combine
import Foundation
import Media
import PencilKit

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
}

class StoryCreationViewModel: StoryCreationViewControllerDisplayable, Actionable {
    var drawingPublisher: CurrentValueSubject<PKDrawing, Never>
    
    var currentDrawing = PKDrawing()
    
    var store: AppStore?
    
    var recordingURL: URL?
    
    var name = "StoryTime-\(UUID())"
    
    var cancellables = Set<AnyCancellable>()
    
    weak var delegate: StoryCreationViewModelDelegate?
    
    var timerViewModel: TimerViewModel
    
    var recordingStateCancellable: AnyCancellable? = nil
    
    init(store: AppStore? = nil) {
        self.store = store
        self.drawingPublisher = CurrentValueSubject<PKDrawing, Never>(store?.state.storyCreationState.currentPagePublisher.value.drawing ?? PKDrawing())
        self.timerViewModel = TimerViewModel()
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

//MARK: - Private
private extension StoryCreationViewModel {
    
    func handleStartRecording() {
        if recordingURL == nil {
            recordingURL = DataLocationModels.recordings(UUID()).URL()
        }
        store?.dispatch(.recording(.startOrResumeRecording(recordingURL)))
        addStateObserverIfNeeded()
    }
    
    func handleDoneButton() {
        AppLifeCycleManager.shared.router.route(to: .loading)
        store?.dispatch(.recording(.finishRecording))
        store?.dispatch(.storyCreation(.update(currentDrawing, recordingURL, delegate?.currentImage())))
        store?.dispatch(.storyCreation(.finishStory(name)))
        let duration = store?.state.storyCreationState.pages.reduce(0) {$0 + $1.duration } ?? 0.0
        let storyURL = DataLocationModels.stories(name).URL()
        store?.dispatch(.dataStore(.addStory(name, storyURL, duration, store?.state.storyCreationState.pages.count ?? 0)))
        store?.dispatch(.dataStore(.save))
        AppLifeCycleManager.shared.router.route(to: .dismissPresentedViewController({
            AppLifeCycleManager.shared.router.route(to: .dismissPresentedViewController(nil))
        }))
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
