//
//  Middleware.swift
//  LonesomeDove
//  Created on 4/13/21.
//

import Combine
import Foundation

typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>?
