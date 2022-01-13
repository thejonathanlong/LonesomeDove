//
//  StoryListState.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 12/22/21.
//

import Combine

enum StoryListAction {
    // The below case needs an associated object that is the viewModel conforming to StoryCardDisplayable
    // Future Jonathan responding to Past Jonathan about this comment. Is this true?
    case toggleFavorite(StoryCardViewModel)
    case newStory
    case readStory(StoryCardViewModel)
    case updateStoryList
    case updatedStoryList([StoryCardViewModel])
}

struct StoryListState {

    var dataStore: DataStorable

    var storyCardViewModels: [StoryCardViewModel] = []

    func addOrRemoveFromFavorite(_ card: StoryCardViewModel) {
        card.isFavorite = !card.isFavorite
    }

    mutating func updateStories() async {
        storyCardViewModels = await dataStore.fetchStories()
    }
}
