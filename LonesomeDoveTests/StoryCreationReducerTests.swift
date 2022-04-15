//
//  StoryCreationReducerTests.swift
//  LonesomeDoveTests
//
//  Created on 4/14/22.
//

@testable import LonesomeDove
import PencilKit
import XCTest

class StoryCreationReducerTests: XCTestCase {
    
    func testNextPageTellsDataStoreToSave() {
        let didSaveExpectation = expectation(description: "save should be called")
        let mockDataStorable = MockStoryDataStorable {
            didSaveExpectation.fulfill()
        }
        var appState = AppState(dataStore: mockDataStorable, dataStoreDelegate: nil)
        storyCreationReducer(state: &appState, action: .nextPage(PKDrawing(), nil, nil, [], nil))
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testPreviousPageTellsDataStoreToSave() {
        let didSaveExpectation = expectation(description: "save should be called")
        let mockDataStorable = MockStoryDataStorable {
            didSaveExpectation.fulfill()
        }
        var appState = AppState(dataStore: mockDataStorable, dataStoreDelegate: nil)
        storyCreationReducer(state: &appState, action: .previousPage(PKDrawing(), nil, nil, [], nil))
        
        waitForExpectations(timeout: 1.0)
    }
}
