//
//  MenuView.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 4/28/22.
//

import SwiftUI

struct MenuView: View {
    var viewModels: [ButtonViewModel]
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(viewModels) {
                UtilityButton(viewModel: $0)
            }
        }
        .padding()
        .background(Color.darkBackground)
        .cornerRadius(12)
    }
}

struct MenuButtonView_Previews: PreviewProvider {
    static var previews: some View {
//        ZStack {
//            Color.black
            MenuView(viewModels: [
                ButtonViewModel(title: "Record",
                                systemImageName: "record.circle",
                                tint: Color.funColor(for: .red)),
                ButtonViewModel(title: "Record",
                                systemImageName: "record.circle",
                                tint: Color.funColor(for: .red))
            ])
//        }
        
            
    }
}
