//
//  Middleware.swift
//  LonesomeDove
//  Created on 4/13/21.
//

import Combine
import Foundation

typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>?

func dataStoreMiddleware(service: StoryDataStorable) -> Middleware<AppState, AppAction> {
    return { _, action in
        switch action {
            case .storyCard(.updateStoryList):
                return Future<AppAction, Never> { promise in
                    Task {
                        let storyCards = await service.fetchDraftsAndStories()
                        promise(.success(AppAction.storyCard(.updatedStoryList(storyCards))))
                    }
                }
                .eraseToAnyPublisher()

            case .storyCard(.readStory(let viewModel)):
                guard viewModel.type == .draft
                else {
                    return Empty().eraseToAnyPublisher()
                }
                return Future<AppAction, Never> { promise in
                    Task {
                        let pages = await service.fetchPages(for: viewModel)
                        promise(.success(AppAction.storyCreation(.initialize(viewModel, pages))))
                    }
                }
                .eraseToAnyPublisher()
            
            case .savedDrawing(.fetchSavedDrawings):
                return Future<AppAction, Never> { promise in
                    Task {
                        let savedDrawings = await service.fetchSavedDrawings()
                        promise(.success(AppAction.savedDrawing(.updateSavedDrawings(savedDrawings))))
                    }
                }
                .eraseToAnyPublisher()

            default:
                break

        }

        return Empty().eraseToAnyPublisher()
    }
}
