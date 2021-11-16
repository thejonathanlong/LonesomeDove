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
    
    var store: AppStore?
    
    let recordingName = "StoryRecording-\(UUID())"
    
    var cancellables = Set<AnyCancellable>()
    
    lazy var recorder = RecordingController(recordingURL: FileManager.default.documentsDirectory.appendingPathComponent(recordingName).appendingPathExtension("aac"))
    
    init(store: AppStore? = nil) {
        self.store = store
        store?.state.mediaState.recorder?
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
    }
    
    func didUpdate(drawing: PKDrawing) {
        store?.dispatch(.drawing(.update(drawing)))
    }
    
    lazy var recordingButton = ButtonViewModel(title: "Record", systemImageName: "record.circle", alternateSysteImageName: "pause.circle.fill", actionTogglesImage: true, tint: .red, alternateImageTint: .white, actionable: self)
    
    func buttons() -> [ButtonViewModel] {
        [recordingButton]
    }
    
    func didPerformAction(type: ButtonViewModel.ActionType, for model: ButtonViewModel) {
        switch type {
            case .main where model == recordingButton:
//                store?.dispatch(.recording(.startOrResumeRecording))
                recorder.startOrResumeRecording()
                
            case .alternate where model == recordingButton:
                store?.dispatch(.recording(.pauseRecording))
                
            default:
                break
        }
    }
}
