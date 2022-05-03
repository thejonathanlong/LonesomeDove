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
                        let speechRecognizer = SpeechRecognizer()
                        
                        let timedStrings = await page
                            .recordingURLs
                            .compactMap { $0 }
                            .asyncMap {
                                await speechRecognizer.generateTimeStrings(for: $0)
                            }
                        
                        promise(.success(AppAction.storyCreation(.updateTextForPage(page, timedStrings, nil))))
                    }
                }.eraseToAnyPublisher()

            default:
                break
        }

        return Empty().eraseToAnyPublisher()
    }
}
