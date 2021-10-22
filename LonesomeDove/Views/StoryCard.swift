//
//  StoryCard.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/21/21.
//

import SwiftUI
import SwiftUIFoundation

protocol StoryCardDisplayable {
    var title: String { get }
    var duration: String { get }
    var numberOfPages: Int { get }
    var image: UIImage { get }
}

struct StoryCard: View {
    let viewModel: StoryCardDisplayable
    
    var body: some View {
        VStack(alignment: .center) {
            Image(uiImage: viewModel.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .cornerRadius(17)
            heading
        }
        .padding()
        .cornerRadius(25, corners: .allCorners, backgroundColor: Color.funColor())
        .shadow(color: Color.defaultShadowColor, radius: 3, x: 1, y: 1)
    }
    
    var heading: some View {
            VStack {
                title
                info
            }
    }
    
    var info: some View {
        HStack {
            Text(viewModel.duration)
            Spacer()
            Text("\(viewModel.numberOfPages) pages")
        }
        .font(.title3)
        .foregroundColor(Color.defaultTextColor)
    }
    
    var title: some View {
        Text(viewModel.title)
            .font(.title2)
            .foregroundColor(Color.defaultTextColor)
    }
}

struct Preview_StoryDisplayable: StoryCardDisplayable {
    var title = "The Great adventures of the Cat"
    var duration = "1:30"
    var image = UIImage(named: "test_image")!
    var numberOfPages = 5
}

struct StoryCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: Array(repeating: .init(.fixed(350)), count: 2), alignment: .top) {
                StoryCard(viewModel: Preview_StoryDisplayable())
                StoryCard(viewModel: Preview_StoryDisplayable())
                StoryCard(viewModel: Preview_StoryDisplayable())
                StoryCard(viewModel: Preview_StoryDisplayable())
            }
        }
        
.previewInterfaceOrientation(.landscapeLeft)
        
    }
}
