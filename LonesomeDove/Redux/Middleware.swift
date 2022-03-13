//
//  Middleware.swift
//  LonesomeDove
//  Created on 4/13/21.
//

import Combine
import Foundation
import Media

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

func mediaMiddleware() -> Middleware<AppState, AppAction> {
    return { _, action in
        switch action {
            case .storyCreation(.generateTextForCurrentPage(let page)):
                return Future<AppAction, Never> { promise in
                    Task {
                        var strings = [TimedStrings?]()
                        for url in page.recordingURLs.compactMap({ $0 }) {
                            let speechRecognizer = SpeechRecognizer(url: url)
                            strings.append(await speechRecognizer.generateTimedStrings())
                        }
                        promise(.success(AppAction.storyCreation(.updateTextForPage(page, strings.compactMap { $0 }))))
                    }
                }.eraseToAnyPublisher()
                
            default:
                break
        }
        
        return Empty().eraseToAnyPublisher()
    }
}
