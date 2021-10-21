//
//  Middleware.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 4/13/21.
//

import Combine
import Foundation

typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>?
