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
            case .storyCreation(.generateTextForCurrentPage(let page)):
                return Future<AppAction, Never> { promise in
                    Task {
                        var strings = [TimedStrings?]()
                        for url in page.recordingURLs.compactMap({ $0 }) {
                            let speechRecognizer = SpeechRecognizer(url: url)
                            strings.append(await speechRecognizer.generateTimedStrings())
                        }
                        promise(.success(AppAction.storyCreation(.updateTextForPage(page, strings.compactMap { $0 }, nil))))
                    }
                }.eraseToAnyPublisher()

            default:
                break
        }

        return Empty().eraseToAnyPublisher()
    }
}
