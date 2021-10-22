//
//  StoryCard.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/21/21.
//

import SwiftUI
import SwiftUIFoundation

protocol StoryDisplayable {
    var title: String { get }
    var duration: String { get }
    var image: UIImage { get }
}

struct StoryCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "xmark")
                .frame(minHeight: 300)
            Text("Title")
                .font(.title)
            Text("0:00")
                .font(.title3)
        }
        .padding()
        .cornerRadius(25, corners: .allCorners, backgroundColor: Color.funColor())
        .shadow(color: Color(.displayP3, red: 0.3, green: 0.3, blue: 0.3, opacity: 0.3), radius: 3, x: 1, y: 1)
        
    }
}

struct StoryCard_Previews: PreviewProvider {
    static var previews: some View {
        StoryCard()
    }
}
