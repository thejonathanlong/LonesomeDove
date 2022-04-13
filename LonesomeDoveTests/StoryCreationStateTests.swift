//
//  StoryCreationStateTests.swift
//  LonesomeDoveTests
//
//  Created on 4/5/22.
//

import Collections
@testable import LonesomeDove
import PencilKit
import XCTest

class StoryCreationStateTests: XCTestCase {
    
    override func setUp() { }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.isNotFirstStory.rawValue)
    }
    
    func testIsFirstStoryIsSetOnInit() {
        XCTAssertFalse(UserDefaults.standard.bool(forKey: UserDefaultKeys.isNotFirstStory.rawValue))
        let state = StoryCreationState()
        XCTAssertTrue(state.isFirstStory)
    }
    
    func testUpdateCurrentPage() {
        var state = StoryCreationState()
        
        XCTAssertEqual(state.currentPage.drawing.strokes.count, 0)
        XCTAssertNil(state.currentPage.text)
        XCTAssertEqual(state.currentPage.index, 0)
        XCTAssertTrue(state.currentPage.recordingURLs.isEmpty)
        
        let newMockDrawing = PKDrawing(strokes: [PKStroke(ink: .init(.pen, color: .blue), path: PKStrokePath(controlPoints: [PKStrokePoint(location: CGPoint(x: 1, y: 1), timeOffset: 1, size: CGSize(width: 100, height: 100), opacity: 1.0, force: 1.0, azimuth: 1.0, altitude: 1.0)], creationDate: Date()))])
        let newRecordingURL = URL.init(fileURLWithPath: "/Users/jlo/blah.txt")
        let newMockImage = UIImage(named: "test_image")
        state.updateCurrentPage(currentDrawing: newMockDrawing, recordingURL: newRecordingURL, image: newMockImage, stickers: [], storyText: nil)
        
        XCTAssertEqual(state.currentPage.drawing, newMockDrawing)
        XCTAssertNil(state.currentPage.text)
        XCTAssertEqual(state.currentPage.index, 0)
        XCTAssertTrue(state.currentPage.recordingURLs.contains(newRecordingURL))
        XCTAssertEqual(state.currentPage.image, newMockImage)
    }
    
    func testMoveToNextPage() {
        var state = StoryCreationState()
        
        XCTAssertEqual(state.currentPage.drawing.strokes.count, 0)
        XCTAssertNil(state.currentPage.text)
        XCTAssertEqual(state.currentPage.index, 0)
        XCTAssertTrue(state.currentPage.recordingURLs.isEmpty)
        
        let newMockDrawing = PKDrawing(strokes: [PKStroke(ink: .init(.pen, color: .blue), path: PKStrokePath(controlPoints: [PKStrokePoint(location: CGPoint(x: 1, y: 1), timeOffset: 1, size: CGSize(width: 100, height: 100), opacity: 1.0, force: 1.0, azimuth: 1.0, altitude: 1.0)], creationDate: Date()))])
        let newRecordingURL = URL.init(fileURLWithPath: "/Users/jlo/blah.txt")
        let newMockImage = UIImage(named: "test_image")
        state.updateCurrentPage(currentDrawing: newMockDrawing, recordingURL: newRecordingURL, image: newMockImage, stickers: [], storyText: nil)
        
        XCTAssertEqual(state.currentPage.drawing, newMockDrawing)
        XCTAssertNil(state.currentPage.text)
        XCTAssertEqual(state.currentPage.index, 0)
        XCTAssertTrue(state.currentPage.recordingURLs.contains(newRecordingURL))
        XCTAssertEqual(state.currentPage.image, newMockImage)
        
        state.moveToNextPage(currentDrawing: state.currentPage.drawing, recordingURL: newRecordingURL, image: newMockImage, stickers: [], storyText: nil)
        
        XCTAssertEqual(state.currentPage.drawing.strokes.count, 0)
        XCTAssertNil(state.currentPage.text)
        XCTAssertEqual(state.currentPage.index, 1)
        XCTAssertTrue(state.currentPage.recordingURLs.isEmpty)
        XCTAssertNil(state.currentPage.image)
    }
    
    func testMoveToPreviousPage() {
        var state = StoryCreationState()
        
        XCTAssertEqual(state.currentPage.drawing.strokes.count, 0)
        XCTAssertNil(state.currentPage.text)
        XCTAssertEqual(state.currentPage.index, 0)
        XCTAssertTrue(state.currentPage.recordingURLs.isEmpty)
        
        let newMockDrawing = PKDrawing(strokes: [PKStroke(ink: .init(.pen, color: .blue), path: PKStrokePath(controlPoints: [PKStrokePoint(location: CGPoint(x: 1, y: 1), timeOffset: 1, size: CGSize(width: 100, height: 100), opacity: 1.0, force: 1.0, azimuth: 1.0, altitude: 1.0)], creationDate: Date()))])
        let newRecordingURL = URL.init(fileURLWithPath: "/Users/jlo/blah.txt")
        let newMockImage = UIImage(named: "test_image")
        
        state.updateCurrentPage(currentDrawing: newMockDrawing, recordingURL: newRecordingURL, image: newMockImage, stickers: [], storyText: nil)
        
        XCTAssertEqual(state.currentPage.drawing, newMockDrawing)
        XCTAssertNil(state.currentPage.text)
        XCTAssertEqual(state.currentPage.index, 0)
        XCTAssertTrue(state.currentPage.recordingURLs.contains(newRecordingURL))
        XCTAssertEqual(state.currentPage.image, newMockImage)
        
        state.moveToNextPage(currentDrawing: state.currentPage.drawing, recordingURL: newRecordingURL, image: newMockImage, stickers: [], storyText: nil)
        
        XCTAssertEqual(state.currentPage.drawing.strokes.count, 0)
        XCTAssertNil(state.currentPage.text)
        XCTAssertEqual(state.currentPage.index, 1)
        XCTAssertTrue(state.currentPage.recordingURLs.isEmpty)
        XCTAssertNil(state.currentPage.image)
        
        state.moveToPreviousPage(currentDrawing: state.currentPage.drawing, recordingURL: newRecordingURL, image: state.currentPage.image, stickers: [], storyText: nil)
        
        XCTAssertEqual(state.currentPage.drawing, newMockDrawing)
        XCTAssertNil(state.currentPage.text)
        XCTAssertEqual(state.currentPage.index, 0)
        XCTAssertTrue(state.currentPage.recordingURLs.contains(newRecordingURL))
        XCTAssertEqual(state.currentPage.image, newMockImage)
    }
    
    func testShowDrawingView() {
        let expectedRoute = Route.newStory(StoryCreationViewModel(store: AppLifeCycleManager.shared.store, name: "Story 1", isFirstStory: true))
        let mockRouter = MockRouter { route in
            XCTAssertEqual(expectedRoute, route)
        }
        let state = StoryCreationState(router: mockRouter)
        state.showDrawingView(numberOfStories: 0)
    }
    
    func testShowDrawingViewForViewModel() {
        let viewModel = StoryCreationViewModel(store: AppLifeCycleManager.shared.store, name: "Story 1", isFirstStory: true)
        let storyCardViewModel = StoryCardViewModel(title: "Story 1", duration: 1, numberOfPages: 0, image: nil, storyURL: URL(fileURLWithPath: "/Users/jlo.txt"))
        let expectedRoute = Route.newStory(viewModel)
        let mockRouter = MockRouter { route in
            XCTAssertEqual(expectedRoute, route)
        }
        let state = StoryCreationState(router: mockRouter)
        state.showDrawingView(for: storyCardViewModel, numberOfStories: 0)
    }
    
    func testShowTextAndRecordingDeleteConfirmation() {
        let expectedViewModel = AlertViewModel(title: LonesomeDoveStrings.textAndRecordingDeleteConfirmationTitle.rawValue,
                                               message: LonesomeDoveStrings.textAndRecordingDeleteConfirmationMessage.rawValue,
                                               actions: [])
        let expectedRoute = Route.alert(expectedViewModel, nil)
        let mockRouter = MockRouter { route in
            XCTAssertEqual(expectedRoute, route)
        }
        let state = StoryCreationState(router: mockRouter)
        state.showTextAndRecordingDeleteConfirmation(page: Page(drawing: PKDrawing(), index: 0, recordingURLs: OrderedSet<URL?>([]), stickers: Set<Sticker>(), pageText: nil))
    }
    
    func testDeleteTextAndRecordingds() {
        let removeItemExpectation = expectation(description: "removeItem should be called")
        
        let expectedURL = URL(fileURLWithPath: "/Users/jlo/abc.txt")
        let page = Page(drawing: PKDrawing(), index: 0, recordingURLs: OrderedSet<URL?>([expectedURL]), stickers: Set<Sticker>(), pageText: nil)
        let mockFileManager = MockFileManageable {
            XCTAssertEqual($0, expectedURL)
            removeItemExpectation.fulfill()
        } fileExists: { _ in
            return true
        }

        let state = StoryCreationState(fileManager: mockFileManager)
        state.deleteTextAndRecordings(for: page)
        waitForExpectations(timeout: 2)
    }
    
    func testCancelAndDeleteCurrentStory() {
        let removeItemExpectation = expectation(description: "removeItem should be called")
        let fileExistsExpectation = expectation(description: "fileExists should be called")
        let completionExpectation = expectation(description: "The completion handler should be called")
        
        let expectedURL = URL(fileURLWithPath: "/Users/jlo/abc.txt")
        let mockFileManager = MockFileManageable {
            XCTAssertEqual($0, expectedURL)
            removeItemExpectation.fulfill()
        } fileExists: {
            XCTAssertEqual($0, expectedURL.path)
            fileExistsExpectation.fulfill()
            return true
        }

        var state = StoryCreationState(fileManager: mockFileManager)
        state.updateCurrentPage(currentDrawing: PKDrawing(), recordingURL: expectedURL, image: nil, stickers: [], storyText: nil)
        state.cancelAndDeleteCurrentStory(named: "Whatever") {
            completionExpectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
}

//MARK: - Make Stuff Equatable
extension Route: Equatable {
    public static func == (lhs: Route, rhs: Route) -> Bool {
        switch(lhs, rhs) {
            case (.alert(let lhsViewModel, _), .alert(let rhsViewModel, _)):
                return lhsViewModel == rhsViewModel
                
            case (.confirmCancelAlert, .confirmCancelAlert):
                return true
                
            case (.dismissPresentedViewController, .dismissPresentedViewController):
                return true
                
            case (.loading, .loading):
                return true
                
            case (.newStory(let lhsViewModel), .newStory(let rhsViewModel)):
                return lhsViewModel == rhsViewModel
                
            case (.readStory, .readStory):
                return true
                
            case (.showStickerDrawer, .showStickerDrawer):
                return true
                
            case (.warning, .warning):
                return true
                
            case (.addStickerToStory, .addStickerToStory):
                return true
                
            default:
                return false
        }
    }
}

extension StoryCreationViewModel: Equatable {
    public static func == (lhs: StoryCreationViewModel, rhs: StoryCreationViewModel) -> Bool {
        lhs.name == rhs.name && lhs.isFirstStory == rhs.isFirstStory
    }
}

extension AlertViewModel: Equatable {
    public static func == (lhs: AlertViewModel, rhs: AlertViewModel) -> Bool {
        lhs.message == rhs.message && lhs.title == rhs.title
    }
}
