//
//  LoadingView.swift
//  LonesomeDove
//  Created on 1/9/22.
//

import SwiftUI

protocol LoadingViewDisplayable: ObservableObject {
    var title: String { get }
}

struct LoadingView<ViewModel>: View where ViewModel: LoadingViewDisplayable {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ProgressView("Saddling the unicorns...")
                Spacer()
            }
            Spacer()
        }
        .background(.regularMaterial)
    }
}

class LoadingView_PreviewViewModel: LoadingViewDisplayable {
    var title: String {
        "Saddling the unicorns..."
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.red
            LoadingView(viewModel: LoadingView_PreviewViewModel())
        }

    }
}
