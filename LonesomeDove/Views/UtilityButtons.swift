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
            } else if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(Color.white)
                    .frame(width: 80, height: 45, alignment: .center)
                    .cornerRadius(12.0)
            } else {
                Text(viewModel.title)
            }
        }
    }
}

//struct UtilityButtons: View {
//    let viewModels: [ButtonViewModel]
//
//    var body: some View {
//        HStack {
//            buttons
//                .padding()
//        }
//        .cornerRadius(12, corners: .allCorners)
//    }
//
//    var buttons: some View {
//        ForEach(viewModels) { viewModel in
//            Button {
//                viewModel.performAction(type: actionType(from: viewModel))
//            } label: {
//                label(from: viewModel)
//                    .tint(viewModel.currentImageName == viewModel.systemImageName ? viewModel.tint : viewModel.alternateImageTint)
//                    .labelStyle(IconOnlyLabelStyle())
//                    .font(.largeTitle)
//            }
//        }
//    }
//
//    func label(from viewModel: ButtonViewModel) -> some View {
//        Group {
//            if let imageName = viewModel.currentImageName {
//                Label(viewModel.title, systemImage: imageName)
//            } else if let image = viewModel.image {
//                Image(uiImage: image)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//            } else {
//                Text(viewModel.title)
//            }
//        }
//    }
//
//    func actionType(from viewModel: ButtonViewModel) -> ButtonViewModel.ActionType {
//        if let _ = viewModel.currentImageName {
//            return .main
//        } else {
//            return .alternate
//        }
//    }
//}

struct UtilityButtons_Previews: PreviewProvider {
    static var previews: some View {
        UtilityButton(viewModel:
            ButtonViewModel(title: "Record",
                            systemImageName: "record.circle",
                            tint: Color.funColor(for: .red)))
    }
}
