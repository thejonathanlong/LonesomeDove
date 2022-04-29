//
//  StoryCardListViewModelTests.swift
//  LonesomeDoveTests
//
//  Created by Jonathan Long on 4/29/22.
//

import Combine
@testable import LonesomeDove
import XCTest

class StoryCardListViewModelTests: XCTestCase {

    func testExitDeleteCallsExitDeleteOnTheStore() {
        let state = AppState()
        let store = AppStore(initialState: state, reducer: appReducer, middlewares: [
            storyCardListviewModelTestMiddleware(verifier: { result in
                XCTAssertTrue(result)
            })
        ])
                
        let viewModel = StoryCardListViewModel<StoryCardViewModel>(store: store)
        viewModel.exitDeleteMode()
        
        func storyCardListviewModelTestMiddleware(verifier: @escaping (Bool) -> Void) -> Middleware<AppState, AppAction> {
            return { _, action in
                switch action {
                    case .storyCard(.exitDeleteMode):
                        verifier(true)
                        return Empty().eraseToAnyPublisher()
                    default:
                        verifier(false)
                        return Empty().eraseToAnyPublisher()
                }
            }
        }
    }
    
    func testEnterDeleteCallsEnterDeleteOnTheStore() {
        let state = AppState()
        let store = AppStore(initialState: state, reducer: appReducer, middlewares: [
            storyCardListviewModelTestMiddleware(verifier: { result in
                XCTAssertTrue(result)
            })
        ])
                
        let viewModel = StoryCardListViewModel<StoryCardViewModel>(store: store)
        viewModel.enterDeleteMode()
        
        func storyCardListviewModelTestMiddleware(verifier: @escaping (Bool) -> Void) -> Middleware<AppState, AppAction> {
            return { _, action in
                switch action {
                    case .storyCard(.enterDeleteMode):
                        verifier(true)
                        return Empty().eraseToAnyPublisher()
                    default:
                        verifier(false)
                        return Empty().eraseToAnyPublisher()
                }
            }
        }
    }

}


