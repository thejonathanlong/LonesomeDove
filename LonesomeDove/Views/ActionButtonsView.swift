//
//  ActionButtonsView.swift
//  LonesomeDove
//  Created on 12/30/21.
//

import SwiftUI

struct ActionButtonsView<TimerViewModel>: View where TimerViewModel: TimerDisplayable {
    var leadingModels: [ButtonViewModel]
    var trailingModels: [ButtonViewModel]
    var timerViewModel: TimerViewModel

    var body: some View {
        HStack {
            leadingViews
            Spacer()
            trailingViews
        }
    }

    var leadingViews: some View {
        VStack {
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
        ActionButtonsView(leadingModels: [ButtonViewModel(title: "Hello"), ButtonViewModel(title: "Hello"), ButtonViewModel(title: "Hola")], trailingModels: [ButtonViewModel(title: "World")], timerViewModel: TimerViewModel())
    }
}
