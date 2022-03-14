//
//  LoggingMiddleware.swift
//  LonesomeDove
//
//  Created on 3/14/22.
//

import Combine
import Foundation
import OSLog

func loggingMiddleware(service: Logger) -> Middleware<AppState, AppAction> {
    return { _, action in
        service.log("Triggerd action: \(action)")
        return Empty().eraseToAnyPublisher()
    }
    
}
