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
}

class StoryCreationViewModel: StoryCreationViewControllerDisplayable, Actionable {
    var drawingPublisher: CurrentValueSubject<PKDrawing, Never>
    
    var currentDrawing = PKDrawing()
    
    var store: AppStore?
    
    var recordingURL: URL?
    
    var cancellables = Set<AnyCancellable>()
    
    weak var delegate: StoryCreationViewModelDelegate?
    
    var timerViewModel: TimerViewModel
    
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
                if recordingURL == nil {
                    recordingURL = DataLocationModels.recordings(UUID()).URL()
                }
                store?.dispatch(.recording(.startOrResumeRecording(recordingURL)))
                
            case .alternate where model == recordingButton:
                store?.dispatch(.recording(.pauseRecording))
            
            case _ where model == previousPageButton:
            	store?.dispatch(.storyCreation(.previousPage(currentDrawing, recordingURL, delegate?.currentImage())))
                recordingURL = nil
                store?.dispatch(.recording(.finishRecording))
            
            case _ where model == nextPageButton:
            	store?.dispatch(.storyCreation(.nextPage(currentDrawing, recordingURL, delegate?.currentImage())))
                recordingURL = nil
                store?.dispatch(.recording(.finishRecording))
        	
        	case _ where model == doneButton:
                store?.dispatch(.recording(.finishRecording))
            	store?.dispatch(.storyCreation(.update(currentDrawing, recordingURL, delegate?.currentImage())))
                store?.dispatch(.storyCreation(.finishStory("MyFirstStory-\(UUID())")))
            	break
            
        	case _ where model == cancelButton:
            AppLifeCycleManager.shared.router.route(to: .dismissPresentedViewController)
                
            default:
                break
        }
    }
}

//MARK: - Private
private extension StoryCreationViewModel {
    func addSubscribers() {
        // Subscriber to recorder state
        store?
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
                }
            }, receiveValue: { [weak self] newState in
                self?.recordingControllerMoved(to: newState)
                
            })
            .store(in: &cancellables)
        
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
    
    func recordingControllerMoved(to newState: RecordingController.State) {
        switch newState {
        	case .timeUpdated(let newTime):
            	self.timerViewModel.time = Int(newTime)
        
        	default:
            	break
        }
    }
}
