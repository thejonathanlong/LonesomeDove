//
//  UtilityButtons.swift
//  LonesomeDove
//  Created on 10/21/21.
//

import SwiftUI
import SwiftUIFoundation

protocol Actionable: AnyObject {
    func didPerformAction(type: ButtonViewModel.ActionType, for model: ButtonViewModel)
}

struct UtilityButton: View {
    @ObservedObject var viewModel: ButtonViewModel

    var body: some View {
        Button {
            viewModel.performAction(type: viewModel.currentAction)
        } label: {
            label(from: viewModel)
                .tint(viewModel.tint)
                .labelStyle(IconOnlyLabelStyle())
                .font(.largeTitle)
        }
        .buttonStyle(ScaledButtonStyle(tintColor: viewModel.tint, pressedScale: 0.8))
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
                            tint: Color.funColor(for: .red)),
            ButtonViewModel(title: "Previous",
                            systemImageName: "arrow.left",
                            tint: .red),
            ButtonViewModel(title: "Next",
                            systemImageName: "arrow.right",
                            tint: .red),
            ButtonViewModel(title: "Next",
                            systemImageName: "checkmark.square.fill",
                            tint: Color.funColor(for: .green))
        ])
    }
}
