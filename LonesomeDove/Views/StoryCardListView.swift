//
//  StoryCardListView.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/22/21.
//

import SwiftUI

struct StoryCardListView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows(), alignment: .top) {
                AddCardView()
                    .frame(width: 590, height: 325)
                    .onTapGesture {
                        store.dispatch(.storyCard(.newStory))
                    }
                ForEach(store.state.storyListState.storyCardViewModels) { cardViewModel in
                    StoryCard(viewModel: cardViewModel)
                        .onTapGesture {
                            store.dispatch(.storyCard(.readStory(cardViewModel)))
                        }
                }
            }
            .padding(32)
        }
    }
    
    func rows() -> [GridItem] {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular):
            return Array(repeating: GridItem(.fixed(325)), count: 2)
        default:
            return Array(repeating: GridItem(.fixed(325)), count: 1)
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

//struct StoryCardListView_Previews: PreviewProvider {
//    static var previews: some View {
//        StoryCardListView(cardListViewModel: StoryCardListViewModel(cards: [Preview_StoryDisplayable(),Preview_StoryDisplayable(),Preview_StoryDisplayable(),Preview_StoryDisplayable()]))
//            .previewInterfaceOrientation(.portraitUpsideDown)
//    }
//}
