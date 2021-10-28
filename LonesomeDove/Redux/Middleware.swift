//
//  Middleware.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 4/13/21.
//

import Combine
import Foundation

typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>?

//func dataStoreMiddleWare(service: DataStorable) -> Middleware<AppState, AppAction> {
//    return { state, action in
//        switch action {
//        case .dataStore(.save):
//            service.save()
//            
//        default:
//            break
//        }
//        
//        return Empty().eraseToAnyPublisher()
//    }
//}
