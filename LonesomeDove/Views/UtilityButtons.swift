//
//  UtilityButtons.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/21/21.
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
    
//    func actionType(from viewModel: ButtonViewModel) -> ButtonViewModel.ActionType {
//        viewModel.currentImageName == viewModel.systemImageName ? .main : .alternate
//    }
    
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

struct ActionButtonsView<TimerViewModel>: View where TimerViewModel: TimerDisplayable{
    var leadingModels: [ButtonViewModel]
    var trailingModels: [ButtonViewModel]
    var timerViewModel: TimerViewModel
    
    var body: some View {
        HStack {
            ForEach(leadingModels) {
                UtilityButton(viewModel: $0)
            }
            TimerView(viewModel: timerViewModel)
            Spacer()
            ForEach(trailingModels) {
                UtilityButton(viewModel: $0)
            }
        }
    }
}

struct StackedViewContainer<Content>: View where Content: View {
    enum Axis {
        case horizontal, vertical
    }
    
    let axis: Axis
    let spacing: CGFloat?
    @ViewBuilder
    let firstContent: Content
    let secondContent: Content
    
    init(axis: Axis = .horizontal,
         spacing: CGFloat = 10,
         @ViewBuilder firstContent: () -> Content,
         @ViewBuilder secondContent: () -> Content) {
        self.axis = axis
        self.spacing = spacing
        self.firstContent = firstContent()
        self.secondContent = secondContent()
        
    }
    
    var body: some View {
        switch axis {
            case .horizontal:
                horizontalBody
                
            case .vertical:
                verticalBody
        }
    }
    
    var horizontalBody: some View {
        HStack(spacing: spacing) {
            firstContent
            Spacer()
            secondContent
            
        }
    }
    
    var verticalBody: some View {
        VStack(spacing: spacing) {
            firstContent
            Spacer()
            secondContent
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
