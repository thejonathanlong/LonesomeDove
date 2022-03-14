//
//  Store.swift
//  LonesomeDove
//  Created on 4/9/21.
//

import Combine
import Foundation
import SwiftUI

typealias AppStore = Store<AppState, AppAction>

final class Store<State, Action>: ObservableObject {

    // Read only access to app state
    @Published private(set) var state: State

    var tasks = [AnyCancellable?]()

    let serialQueue = DispatchQueue(label: "com.jlo.store.serial.queue")

    private let reducer: Reducer<State, Action>
    let middlewares: [Middleware<State, Action>]
    private var middlewareCancellables: Set<AnyCancellable> = []

    init(initialState: State,
         reducer: @escaping Reducer<State, Action>,
         middlewares: [Middleware<State, Action>] = []) {
        self.state = initialState
        self.reducer = reducer
        self.middlewares = middlewares
    }

    // The dispatch function.
    func dispatch(_ action: Action) {
        reducer(&state, action)

        // Dispatch all middleware functions
        for mw in middlewares {
            guard let middleware = mw(state, action) else {
                break
            }
//            var can: AnyCancellable?
//            can =
            middleware
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] in
                    guard let self = self
//                          let can = can
                    else { return }
                    self.dispatch($0)
//                    can.cancel()
//                    self.middlewareCancellables.remove(can)
                })
                .store(in: &middlewareCancellables)
//            if let can = can {
//                middlewareCancellables.insert(can)
//            }

        }
    }
}
