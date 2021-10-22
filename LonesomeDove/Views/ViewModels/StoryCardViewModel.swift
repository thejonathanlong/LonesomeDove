//
//  StoryCardViewModel.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/22/21.
//

import UIKit

class StoryCardViewModel: StoryCardDisplayable {
    var title: String = ""
    
    var duration: String = ""
    
    var numberOfPages: Int = 5
    
    var image: UIImage = UIImage()
    
    var isFavorite: Bool = false
    
    var id = UUID()
    
    var store: AppStore?
    
    init(store: AppStore? = nil) {
        self.store = store
    }
    
    func toggleFavorite() {
        store?.dispatch(.storyCard(.toggleFavorite(self)))
    }
}
