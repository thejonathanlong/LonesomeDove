//
//  ActionButtonsView.swift
//  LonesomeDove
//  Created on 12/30/21.
//

import SwiftUI

struct StoryCreationControlsView<ViewModel>: View where ViewModel: StoryCreationViewControllerDisplayable {

    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        HStack {
            leadingViews
            HStack(spacing: 20) {
                Spacer()
                ZStack(alignment: .leading) {
                    if viewModel.storyNameViewModel.text.isEmpty {
                        textFieldPrompt
                    }
                    TextField("", text: $viewModel.storyNameViewModel.text)
                        .foregroundColor(.white)
                }

                trailingViews
            }
            .ignoresSafeArea(.keyboard)
        }
        .ignoresSafeArea(.keyboard)
    }

    var textFieldPrompt: Text {
        Text(viewModel.storyNameViewModel.placeholder)
            .foregroundColor(Color.white.opacity(0.6))
    }

    var leadingViews: some View {
        HStack {
            leadingButtons
            if let timerViewModel = viewModel.timerViewModel {
                TimerView(viewModel: timerViewModel)
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }
            Text("Page \(viewModel.pageNumber)")
                .foregroundColor(.white)
        }
    }

    var leadingButtons: some View {
        HStack {
            ForEach(viewModel.leadingButtons()) {
                UtilityButton(viewModel: $0)
            }
        }
    }

    var trailingViews: some View {
        ForEach(viewModel.trailingButtons()) {
            UtilityButton(viewModel: $0)
        }
    }
}

 struct ActionButtonsView_Previews: PreviewProvider {
     static var viewModel: StoryCreationViewModel {
         StoryCreationViewModel(store: nil, name: "Hello", isFirstStory: false, timerViewModel: nil)
     }
    static var previews: some View {
        StoryCreationControlsView<StoryCreationViewModel>().environmentObject(viewModel)
            .background(Color.darkBackground)
    }
 }
