//
//  AppState.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 4/13/21.
//

import Foundation
import PencilKit
import Media

struct AppState {
    lazy var drawingState: DrawingState = DrawingState()
    lazy var storyListState = StoryListState()
    var mediaState = MediaState()
    
    var dataStore: DataStorable
    
    init(dataStore: DataStorable = DataStore(),
         dataStoreDelegate: DataStoreDelegate? = nil) {
        self.dataStore = dataStore
        self.dataStore.delegate = dataStoreDelegate
    }
}

struct DrawingState {
    
    struct Page {
        var drawing: PKDrawing
        let index: Int
    }
    
    var pages = [Page]()
    
    var currentPage = Page(drawing: PKDrawing(), index: 0)
    
    func showDrawingView() {
        AppLifeCycleManager.shared.router.route(to: .newStory(DrawingViewModel(store: AppLifeCycleManager.shared.store)))
    }
    
    mutating func addNextPage(drawing: PKDrawing) {
        if !drawing.strokes.isEmpty && !currentPage.drawing.strokes.isEmpty {
            currentPage.drawing = drawing
            pages.append(currentPage)
        }
        
        if currentPage.index >= pages.count {
            currentPage = Page(drawing: PKDrawing(), index: currentPage.index + 1)
        } else {
            currentPage = pages[currentPage.index + 1]
        }
    }
    
    mutating func goToPreviousPage(currentDrawing: PKDrawing) {
        let currentIndex = currentPage.index
        
        if !currentDrawing.strokes.isEmpty {
            currentPage.drawing = currentDrawing
            pages[currentIndex] = currentPage
        }
        
        if currentPage.index > 0 {
            currentPage = pages[currentIndex - 1]
        }
    }
}

struct StoryListState {
    func addOrRemoveFromFavorite(_ card: StoryCardViewModel) {
        card.isFavorite = !card.isFavorite
    }
}

struct MediaState {
        
    var recorder: RecordingController?

    var currentRecordingURL: URL?
    
    mutating func startRecording(to URL: URL?) {
        defer {
            recorder?.startOrResumeRecording()
        }
        guard let _ = recorder,
              let _ = URL else {
                  recorder = RecordingController(recordingURL: URL)
                  currentRecordingURL = URL
                  return
        }
    }
    
    func pauseRecording() {
        recorder?.pauseRecording()
    }
    
    mutating func finishRecording() {
        recorder?.finishRecording()
        currentRecordingURL = nil
    }
}
