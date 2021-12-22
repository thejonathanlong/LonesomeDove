//
//  StoryListState.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 12/22/21.
//

struct StoryListState {
    func addOrRemoveFromFavorite(_ card: StoryCardViewModel) {
        card.isFavorite = !card.isFavorite
    }
}
