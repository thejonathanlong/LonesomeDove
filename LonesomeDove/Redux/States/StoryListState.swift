//
//  StoryListState.swift
//  LonesomeDove
//  Created on 12/22/21.
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
    case enterDeleteMode
    case exitDeleteMode
}

struct StoryListState {

    enum CardState {
        case normal
        case deleteMode
    }

    var dataStore: StoryDataStorable

    var storyCardViewModels: [StoryCardViewModel] = []

    var cardState: CardState

    func addOrRemoveFromFavorite(_ card: StoryCardViewModel) {
        card.isFavorite = !card.isFavorite
    }

    mutating func updateStories() async {
        storyCardViewModels = await dataStore.fetchStories()
    }
}
