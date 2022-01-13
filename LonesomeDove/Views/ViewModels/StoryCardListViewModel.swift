//
//  StoryCardListViewModel.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/22/21.
//

import Foundation

struct StoryCardListViewModel<CardViewModel> where CardViewModel: StoryCardDisplayable {
    let cards: [CardViewModel]
    var store: AppStore?

    init(cards: [CardViewModel], store: AppStore? = nil) {
        self.cards = cards
        self.store = store
    }

    func addNewStory() {
        store?.dispatch(.storyCard(.newStory))
    }

    func readStory(_ card: CardViewModel) {
        guard let card = card as? StoryCardViewModel else { return }
        store?.dispatch(.storyCard(.readStory(card)))
    }
}
