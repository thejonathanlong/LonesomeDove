//
//  Middleware.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 4/13/21.
//

import Combine
import Foundation

typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>?

func dataStoreMiddleware(service: DataStorable) -> Middleware<AppState, AppAction> {
    return { _, action in
        switch action {
            case .storyCard(.updateStoryList):
                return Future<AppAction, Never> { promise in
                    Task {
                        let storyCards = await service.fetchStories()
                        promise(.success(AppAction.storyCard(.updatedStoryList(storyCards))))
                    }
                }
                .eraseToAnyPublisher()

            default:
                break

        }

        return Empty().eraseToAnyPublisher()
    }
}
