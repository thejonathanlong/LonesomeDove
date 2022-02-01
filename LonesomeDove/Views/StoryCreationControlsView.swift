//
//  ActionButtonsView.swift
//  LonesomeDove
//  Created on 12/30/21.
//

import SwiftUI

struct StoryCreationControlsView<TimerViewModel>: View where TimerViewModel: TimerDisplayable {
    var leadingModels: [ButtonViewModel]
    var trailingModels: [ButtonViewModel]
    var timerViewModel: TimerViewModel
    @ObservedObject var textFieldViewModel: TextFieldViewModel

    var body: some View {
        HStack {
            leadingViews
            HStack(spacing: 50) {
                Spacer()
                ZStack(alignment: .leading) {
                    if textFieldViewModel.text.isEmpty {
                        textFieldPrompt
                    }
                    TextField("", text: $textFieldViewModel.text)
                        .foregroundColor(.white)
                }
                
//                    .foregroundColor(.white)
//                    .textFieldStyle(.roundedBorder)
                Spacer()
            }
            
            trailingViews
        }
    }
    
    var textFieldPrompt: Text {
        Text(textFieldViewModel.placeholder)
            .foregroundColor(Color.white.opacity(0.6))
//            .accentColor(.green)
    }

    var leadingViews: some View {
        HStack {
            leadingButtons
            TimerView(viewModel: timerViewModel)
                .font(.title3.bold())
                .foregroundColor(.white)
        }
    }

    var leadingButtons: some View {
        HStack {
            ForEach(leadingModels) {
                UtilityButton(viewModel: $0)
            }
        }
    }

    var trailingViews: some View {
        ForEach(trailingModels) {
            UtilityButton(viewModel: $0)
        }
    }
}

struct ActionButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        StoryCreationControlsView(leadingModels: [ButtonViewModel(title: "Hello"), ButtonViewModel(title: "Hello"), ButtonViewModel(title: "Hola")], trailingModels: [ButtonViewModel(title: "World")], timerViewModel: TimerViewModel(),
        textFieldViewModel: TextFieldViewModel(placeholder: "Story X"))
            .background(Color.red)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
