//
//  MediaMiddleware.swift
//  LonesomeDove
//
//  Created on 3/14/22.
//

import Combine
import Foundation
import Media
import UIKit

func mediaMiddleware() -> Middleware<AppState, AppAction> {
    return { _, action in
        switch action {
            case .storyCreation(.generateTextForCurrentPage(let page, let url)):
                return Future<AppAction, Never> { promise in
                    Task {
                        let speechRecognizer = SpeechRecognizer()
                        let timedString = await speechRecognizer.generateTimeStrings(for: url)
                        promise(.success(AppAction.storyCreation(.updateTextForPage(page, url, [timedString].compactMap { $0 }, nil))))
                    }
                }.eraseToAnyPublisher()

            default:
                break
        }

        return Empty().eraseToAnyPublisher()
    }
}
