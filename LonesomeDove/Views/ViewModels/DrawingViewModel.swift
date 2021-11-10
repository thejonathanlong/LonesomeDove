//
//  DrawingViewModel.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/22/21.
//

import Foundation
import PencilKit

class DrawingViewModel: DrawingViewControllerDisplayable, Actionable {
    
    var store: AppStore?
    
    init(store: AppStore? = nil) {
        self.store = store
    }
    
    func didUpdate(drawing: PKDrawing) {
        store?.dispatch(.drawing(.update(drawing)))
    }
    
    func buttons() -> [ButtonViewModel] {
        [
            ButtonViewModel(title: "Record", systemImageName: "record.circle", alternateSysteImageName: "pause.circle.fill", actionTogglesImage: true, tint: .red, alternateImageTint: .white, actionable: self)
        ]
    }
    
    func didPerformAction(type: ButtonViewModel.ActionType) {
        switch type {
            case .main:
                store?.dispatch(.recording(.startRecording))
            case .alternate:
                store?.dispatch(.recording(.pauseRecording))
        }
    }
}
