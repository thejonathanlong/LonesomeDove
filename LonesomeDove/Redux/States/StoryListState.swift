//
//  StoryListState.swift
//  LonesomeDove
//  Created on 12/22/21.
//

import Combine
import Collections
import Foundation

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
    case shareStory(URL?)

    var description: String {
        var base = "StoryListAction "
        
        switch self {
            case .toggleFavorite(let storyCardViewModel):
                base += "Toggle Favorite viewModel: \(storyCardViewModel)"
                
            case .newStory:
                base += "New Story"
                
            case .readStory(let storyCardViewModel):
                base += "Read Story viewModel: \(storyCardViewModel)"
                
            case .updateStoryList:
                base += "Update Story List"
                
            case .updatedStoryList(let storyList):
                base += "Updated Story List: \(storyList)"
                
            case .enterDeleteMode:
                base += "Enter Delete Mode"
                
            case .deleteStory(let storyCardViewModel):
                base += "Delete Story viewModel: \(storyCardViewModel)"
                
            case .exitDeleteMode:
                base += "Exit Delete Mode"
                
            case .shareStory(let url):
                base += "shareStory url: \(url?.path ?? "nil")"
        }
        
        return base
    }
}

struct StoryListState: Equatable {
    static func == (lhs: StoryListState, rhs: StoryListState) -> Bool {
        lhs.storyCardViewModels == rhs.storyCardViewModels
    }

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

            case .add:
                break
        }
    }

    mutating func updateStories(newStories: [StoryCardViewModel]) {
        if storyCardViewModels.isEmpty {
            storyCardViewModels.append(contentsOf: newStories)
        } else {
            storyCardViewModels = OrderedSet<StoryCardViewModel>()
            storyCardViewModels.append(contentsOf: newStories)
        }
    }

    func readStory(storyCardViewModel: StoryCardViewModel) {
        AppLifeCycleManager.shared.router.route(to: .readStory(storyCardViewModel))
    }
    
    func shareStory(url: URL?) {
        AppLifeCycleManager.shared.router.route(to: .shareStory(url))
    }
}

func storyListReducer(state: inout AppState, action: StoryListAction) {
    switch action {
        case .toggleFavorite(let storyCardViewModel):
            state.storyListState.addOrRemoveFromFavorite(storyCardViewModel)

        case .newStory:
            state.storyCreationState.showDrawingView(numberOfStories: state.storyListState.storyCardViewModels.count)

        case .readStory(let viewModel):
            if viewModel.type == .finished {
                state.storyListState.readStory(storyCardViewModel: viewModel)
            } else if viewModel.type == .draft {
                state.storyCreationState.showDrawingView(for: viewModel, numberOfStories: state.storyListState.storyCardViewModels.count)
            }

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
            
        case .shareStory(let url):
            state.storyListState.shareStory(url: url)
    }
}
