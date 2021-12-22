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
    var documentsDirectory: URL {
        urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

class DrawingViewModel: DrawingViewControllerDisplayable, Actionable {
    
    var drawingPublisher: CurrentValueSubject<PKDrawing, Never>
    
    var store: AppStore?
    
    let recordingName = "StoryRecording-\(UUID())"
    
    var cancellables = Set<AnyCancellable>()
    
    init(store: AppStore? = nil) {
        self.store = store
        self.drawingPublisher = CurrentValueSubject<PKDrawing, Never>(store?.state.drawingState.currentPagePublisher.value.drawing ?? PKDrawing())
        addSubscribers()
    }
    
    func didUpdate(drawing: PKDrawing) {
        store?.dispatch(.drawing(.update(drawing)))
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
            	store?.dispatch(.recording(.startOrResumeRecording))
                
            case .alternate where model == recordingButton:
                store?.dispatch(.recording(.pauseRecording))
                
            case .main where model == previousPageButton:
                store?.dispatch(.recording(.startOrResumeRecording))
            
            case .alternate where model == previousPageButton:
                store?.dispatch(.recording(.pauseRecording))
            
            case .main where model == nextPageButton:
                store?.dispatch(.recording(.startOrResumeRecording))
            
            case .alternate where model == nextPageButton:
                store?.dispatch(.recording(.pauseRecording))
        	
        case .main where model == doneButton:
            //WARNING: Do this right
            break
            
        case .main where model == cancelButton:
            //WARNING: Do this right
            break
                
            default:
                break
        }
    }
}

//MARK: - Private
private extension DrawingViewModel {
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
            }, receiveValue: { newState in
                // Might have to update some buttons here
                
            })
            .store(in: &cancellables)
        
        store?
            .state
            .drawingState
            .currentPagePublisher
            .map {$0.drawing}
            .sink { [weak self] in self?.drawingPublisher.send($0) }
            .store(in: &cancellables)
    }
}
