//
//  ControlsView.swift
//  LonesomeDove
//  Created on 12/30/21.
//

import SwiftUI

protocol ViewProvider: Identifiable {
    associatedtype ViewType: View
    func view() -> ViewType
}

protocol ControlsViewDisplayable {
    associatedtype ViewProvider
    var controls: [ViewProvider] { get }
}

struct ControlsViewModel<ViewModel> where ViewModel: ViewProvider {
    var viewProviders: [ViewModel]
}

struct ControlsView

struct ControlsView: View {
//    var leadingModels: [ButtonViewModel]
//    var trailingModels: [ButtonViewModel]
//    var timerViewModel: TimerViewModel
//    var viewProviders: [ViewModel]
    var viewModel: ControlsViewModel<<#ViewModel: ViewProvider#>>

    var body: some View {
        HStack {
            ForEach(viewProviders) {
                $0.view()
            }
//            leadingViews
//            leadingButtons
//            TimerView(viewModel: timerViewModel)
//                .font(.title3.bold())
//                .foregroundColor(.white)
//            Spacer()
//            TextField("Story 4", text: .constant("name"))
//                .font(.title)
//                .textFieldStyle(.automatic)
//            Spacer()
//            trailingViews
        }
    }

//    var leadingViews: some View {
//        VStack {
//            leadingButtons
//            TimerView(viewModel: timerViewModel)
//                .font(.title3.bold())
//                .foregroundColor(.white)
//        }
//    }

//    var leadingButtons: some View {
//        HStack {
//            ForEach(leadingModels) {
//                UtilityButton(viewModel: $0)
//            }
//        }
//    }
//
//    var trailingViews: some View {
//        ForEach(trailingModels) {
//            UtilityButton(viewModel: $0)
//        }
//    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(viewProviders:
                            [ButtonViewModel(title: "Hello"),
                             ButtonViewModel(title: "Hello"),
                             ButtonViewModel(title: "Hola"),
                             ButtonViewModel(title: "World")])
            .background(Color.blue)
    }
}
