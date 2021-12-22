//
//  AppState.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 4/13/21.
//

import Combine
import Foundation
import PencilKit
import Media

struct AppState {
    lazy var storyListState = StoryListState()
    var storyCreationState: StoryCreationState = StoryCreationState()
    var mediaState = MediaState()
    
    var dataStore: DataStorable
    
    init(dataStore: DataStorable = DataStore(),
         dataStoreDelegate: DataStoreDelegate? = nil) {
        self.dataStore = dataStore
        self.dataStore.delegate = dataStoreDelegate
    }
}

struct StoryCreationState {
    
    var pages = [Page]()
    
    var currentPagePublisher = CurrentValueSubject<Page, Never>(Page(drawing: PKDrawing(), index: 0, recordingURLs: []))
    
    var currentPage: Page {
        get {
            currentPagePublisher.value
        }
        set(newPage) {
            currentPagePublisher.value = newPage
        }
    }
    
    func showDrawingView() {
        AppLifeCycleManager.shared.router.route(to: .newStory(StoryCreationViewModel(store: AppLifeCycleManager.shared.store)))
    }
    
    mutating func moveToNextPage(currentDrawing: PKDrawing, recordingURL: URL?) {
        currentPage.drawing.append(currentDrawing)
        currentPage.recordingURLs.append(recordingURL)
        if pages.contains(currentPage) {
            pages[currentPage.index] = currentPage
        } else {
            pages.append(currentPage)
        }
        
        
        if currentPage.index + 1 >= pages.count {
            currentPage = Page(drawing: PKDrawing(), index: currentPage.index + 1, recordingURLs: [])
        } else {
            currentPage = pages[currentPage.index + 1]
        }
    }
    
    mutating func moveToPreviousPage(currentDrawing: PKDrawing, recordingURL: URL?) {
        let currentIndex = currentPage.index
        currentPage.drawing.append(currentDrawing)
        currentPage.recordingURLs.append(recordingURL)
        if currentIndex < pages.count {
            pages[currentIndex] = currentPage
        } else {
            pages.append(currentPage)
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
        recorder = nil
    }
}
