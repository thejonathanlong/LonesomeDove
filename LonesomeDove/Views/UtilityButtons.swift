//
//  UtilityButtons.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/21/21.
//

import SwiftUI
import SwiftUIFoundation

protocol Actionable: AnyObject {
    func didPerformAction(type: ButtonViewModel.ActionType)
}

class ButtonViewModel: Identifiable, ObservableObject {
    
    enum ActionType {
        case main
        case alternate
    }
    
    var id = UUID()
    var title: String
    var systemImageName: String?
    var alternateSystemImageName: String?
    var currentImageName: String?
    var actionTogglesImage: Bool
    var tint: Color?
    var alternateImageTint: Color?
    weak var actionable: Actionable?
    
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
        actionable?.didPerformAction(type: type)
    }
}

struct UtilityButtons: View {
    let viewModels: [ButtonViewModel]
    
    var body: some View {
        HStack {
            buttons
                .padding()
        }
        .cornerRadius(12, corners: .allCorners)
    }
    
    var buttons: some View {
        ForEach(viewModels) { viewModel in
            Button {
                viewModel.performAction(type: actionType(from: viewModel))
            } label: {
                label(from: viewModel)
                    .tint(viewModel.tint)
                    .labelStyle(IconOnlyLabelStyle())
                    .font(.largeTitle)
            }
        }
    }
    
    func label(from viewModel: ButtonViewModel) -> some View {
        Group {
            if let imageName = viewModel.currentImageName {
                Label(viewModel.title, systemImage: imageName)
            } else {
                Text(viewModel.title)
            }
        }
    }
    
    func actionType(from viewModel: ButtonViewModel) -> ButtonViewModel.ActionType {
        if let _ = viewModel.currentImageName {
            return .main
        } else {
            return .alternate
        }
    }
}

struct UtilityButtons_Previews: PreviewProvider {
    static var previews: some View {
        UtilityButtons(viewModels: [
            ButtonViewModel(title: "Record",
                            systemImageName: "record.circle",
                            tint: .white),
            ButtonViewModel(title: "Previous",
                            systemImageName: "arrow.left",
                            tint: .white),
            ButtonViewModel(title: "Next",
                            systemImageName: "arrow.right",
                            tint: .white)
        ])
    }
}
