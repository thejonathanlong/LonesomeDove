//
//  AddCardView.swift
//  LonesomeDove
//  Created on 10/22/21.
//

import SwiftUI

struct AddCardView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Image(systemName: "plus.circle")
                    .font(.largeTitle)
                    .foregroundColor(.funColor(for: .purple))
                Spacer()
            }
        }
        .frame(maxWidth: 328, maxHeight: 300)
        .cornerRadius(25, corners: .allCorners, backgroundColor: Color.white)
        .background(RoundedRectangle(cornerRadius: 25).stroke(Color.defaultTextColor, lineWidth: 4))
        .shadow(color: Color.defaultShadowColor, radius: 3, x: 1, y: 1)
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView()
    }
}
