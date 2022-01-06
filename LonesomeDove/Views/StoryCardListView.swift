//
//  StoryCardListView.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/22/21.
//

import SwiftUI

struct StoryCardListView<CardViewModel>: View where CardViewModel: StoryCardDisplayable {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    let cardListViewModel: StoryCardListViewModel<CardViewModel>
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows(), alignment: .top) {
                AddCardView()
                    .frame(width: 400, height: 350)
                    .onTapGesture {
                        cardListViewModel.addNewStory()
                    }
                ForEach(cardListViewModel.cards) { cardViewModel in
                    StoryCard(viewModel: cardViewModel)
                        .onTapGesture {
                            cardListViewModel.readStory(cardViewModel)
                        }
                }
            }
            .padding(16)
        }
    }
    
    func rows() -> [GridItem] {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular):
            return Array(repeating: GridItem(.fixed(350)), count: UIDevice.current.orientation.isLandscape ? 2 : 3)
        default:
            return Array(repeating: GridItem(.fixed(350)), count: 1)
        }
        
    }
}

struct AddViewModel: StoryCardDisplayable {
    var storyURL: URL = FileManager.documentsDirectory
    
    func toggleFavorite() {
    
    }
    
    var title: String {
        ""
    }
    
    var duration: String {
        ""
    }
    
    var numberOfPages: Int {
        0
    }
    
    var image: UIImage {
        UIImage(systemName: "plus.circle") ?? UIImage()
    }
    
    var isFavorite: Bool {
        false
    }
    
    var id = UUID()
    
    
}

struct StoryCardListView_Previews: PreviewProvider {
    static var previews: some View {
        StoryCardListView(cardListViewModel: StoryCardListViewModel(cards: [Preview_StoryDisplayable(),Preview_StoryDisplayable(),Preview_StoryDisplayable(),Preview_StoryDisplayable()]))
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}
