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
