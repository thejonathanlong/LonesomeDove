//
//  InfoDialogView.swift
//  LonesomeDove
//
//  Created on 2/26/22.
//

import SwiftUI
import SwiftUIFoundation

struct InfoDialogView: View {
    var title: String
    var description: String
    var body: some View {
        VStack {
            Text(title)
                .foregroundColor(.white)
                .font(.title2)
            Divider()
                .background(.white)
            Text(description)
                .foregroundColor(.white)
                .font(.body)
        }
        .padding()
        .frame(maxWidth: 300)
        .cornerRadius(25, corners: .allCorners, backgroundColor: Color.darkBackground)
        .shadow(color: .darkBackground.opacity(0.5), radius: 1, x: -1, y: 1)

    }
}

struct InfoDialogView_Previews: PreviewProvider {
    static var previews: some View {
        InfoDialogView(title: "Start/Stop Recording Button", description: "Start and stop the audio recording. Every page needs audio to be included in the final product.")
    }
}
