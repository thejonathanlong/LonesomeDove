//
//  ButtonViewModel.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 11/30/21.
//

import Foundation
import SwiftUI

class ButtonViewModel: Identifiable, ObservableObject, Equatable {
    
    enum ActionType {
        case main
        case alternate
    }
    
    var id = UUID()
    var title: String
    var systemImageName: String?
    var alternateSystemImageName: String?
    @Published var currentImageName: String?
    var actionTogglesImage: Bool
    var tint: Color?
    var alternateImageTint: Color?
    weak var actionable: Actionable?
    
    var currentAction: ActionType {
        currentImageName == systemImageName ? .main : .alternate
    }
    
    init(title: String,
         systemImageName: String? = nil,
         alternateSysteImageName: String? = nil,
         actionTogglesImage: Bool = true,
         tint: Color? = nil,
         alternateImageTint: Color? = nil,
         actionable: Actionable? = nil) {
        self.title = title
        self.systemImageName = systemImageName
        self.alternateSystemImageName = alternateSysteImageName
        self.actionTogglesImage = actionTogglesImage
        self.tint = tint
        self.actionable = actionable
        self.currentImageName = systemImageName
    }
    
    func performAction(type: ActionType) {
        if actionTogglesImage {
            currentImageName = currentImageName == systemImageName ? alternateSystemImageName : systemImageName
        }
        actionable?.didPerformAction(type: type, for: self)
    }
    
    static func == (lhs: ButtonViewModel, rhs: ButtonViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
