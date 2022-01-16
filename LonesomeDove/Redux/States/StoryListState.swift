//
//  StoryListState.swift
//  LonesomeDove
//  Created on 12/22/21.
//

import Combine
import Collections

enum StoryListAction {
    // The below case needs an associated object that is the viewModel conforming to StoryCardDisplayable
    // Future Jonathan responding to Past Jonathan about this comment. Is this true?
    case toggleFavorite(StoryCardViewModel)
    case newStory
    case readStory(StoryCardViewModel)
    case updateStoryList
    case updatedStoryList([StoryCardViewModel])
    case enterDeleteMode
    case deleteStory(StoryCardViewModel)
    case exitDeleteMode
}

struct StoryListState {

    enum CardState {
        case normal
        case deleteMode
    }

    var dataStore: StoryDataStorable

    private(set) var storyCardViewModels = OrderedSet<StoryCardViewModel>()

    var cardState: CardState

    func addOrRemoveFromFavorite(_ card: StoryCardViewModel) {
        card.isFavorite = !card.isFavorite
    }

    mutating func updateStories() async {
        let draftsAndStories = await dataStore.fetchDraftsAndStories()
        storyCardViewModels.append(contentsOf: draftsAndStories)
    }

    func deleteStory(_ card: StoryCardViewModel) {
        switch card.type {
            case .finished:
                dataStore.deleteStory(named: card.title)

            case .draft:
                dataStore.deleteDraft(named: card.title)
        }
    }

    mutating func updateStories(newStories: [StoryCardViewModel]) {
        storyCardViewModels.append(contentsOf: newStories)
    }
}

func storyListReducer(state: inout AppState, action: StoryListAction) {
    switch action {
        case .toggleFavorite(let storyCardViewModel):
            state.storyListState.addOrRemoveFromFavorite(storyCardViewModel)

        case .newStory:
            state.storyCreationState.showDrawingView()

        case .readStory:
            break

        case .updateStoryList:
            break

        case .updatedStoryList(let viewModels):
            state.storyListState.updateStories(newStories: viewModels)

        case .enterDeleteMode:
            state.storyListState.cardState = .deleteMode

        case .deleteStory(let viewModel):

            state.storyListState.deleteStory(viewModel)

        case .exitDeleteMode:
            state.storyListState.cardState = .normal
    }
}
