//
//  UtilityButtons.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/21/21.
//

import SwiftUI
import SwiftUIFoundation

protocol ButtonDisplayable: Identifiable {
    var title: String { get }
    var systemImageName: String? { get }
    var alternateSystemImageName: String? { get }
    var usesAlternateImage: Bool { get }
    var action: () -> Void { get }
    var tint: Color? { get }
}

extension ButtonDisplayable {
    var id: String {
        return title
    }
}

struct UtilityButtons<ViewModel>: View where ViewModel: ButtonDisplayable {
    let viewModels: [ViewModel]
    
    var body: some View {
        HStack {
            buttons
                .padding()
        }
        .cornerRadius(12, corners: .allCorners, backgroundColor: .darkBackground)
    }
    
    var buttons: some View {
        ForEach(viewModels) { viewModel in
            Button(action: viewModel.action) {
                label(from: viewModel)
                    .tint(viewModel.tint)
                    .labelStyle(IconOnlyLabelStyle())
                    .font(.largeTitle)
            }
        }
    }
    
    func label(from viewModel: ViewModel) -> some View {
        Group {
            if !viewModel.usesAlternateImage,
               let systemImageName = viewModel.systemImageName {
                Label(viewModel.title, systemImage: systemImageName)
            } else if viewModel.usesAlternateImage,
                      let systemImageName = viewModel.alternateSystemImageName {
                Label(viewModel.title, systemImage: systemImageName)
            }
        }
    }
}

struct Preview_ButtonDisplayable: ButtonDisplayable {
    var title: String = "Record"
    
    var imageName: String?
    
    var systemImageName: String?
    
    var alternateSystemImageName: String?
    
    var usesAlternateImage: Bool {
        false
    }
    
    var action: () -> Void = {}
    
    var tint: Color?
    
    init(title: String, systemImageName: String, tint: Color? = nil) {
        self.title = title
        self.systemImageName = systemImageName
        self.tint = tint ?? .white
    }
}

struct UtilityButtons_Previews: PreviewProvider {
    static var previews: some View {
        UtilityButtons(viewModels: [
            Preview_ButtonDisplayable(title: "Record", systemImageName: "record.circle", tint: .white),
            Preview_ButtonDisplayable(title: "Previous", systemImageName: "arrow.left"),
            Preview_ButtonDisplayable(title: "Next", systemImageName: "arrow.right"),
                                   ])
    }
}
