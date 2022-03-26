//
//  DatastoreMiddleware.swift
//  LonesomeDove
//
//  Created on 3/14/22.
//

import Combine
import Foundation

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

            case .sticker(.fetchStickers):
                return Future<AppAction, Never> { promise in
                    Task {
                        let stickers = await service.fetchStickers()
                        promise(.success(AppAction.sticker(.updateStickers(stickers))))
                    }
                }
                .eraseToAnyPublisher()

            default:
                break
        }

        return Empty().eraseToAnyPublisher()
    }
}
