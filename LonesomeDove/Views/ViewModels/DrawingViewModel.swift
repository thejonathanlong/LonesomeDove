//
//  DrawingViewModel.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/22/21.
//

import Foundation
import PencilKit

struct DrawingViewModel: DrawingViewControllerDisplayable {
    
    var store: AppStore?
    
    func didUpdate(drawing: PKDrawing) {
        store?.dispatch(.drawing(.update(drawing)))
    }
}
