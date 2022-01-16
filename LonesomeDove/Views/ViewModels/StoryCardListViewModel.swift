//
//  StoryCardListViewModel.swift
//  LonesomeDove
//  Created on 10/22/21.
//

import Foundation
import UIKit

class StoryCardListViewModel<CardViewModel> where CardViewModel: StoryCardDisplayable {
    var store: AppStore?

    var toBeDeleted: CardViewModel?

    init(store: AppStore? = nil) {
        self.store = store
        self.toBeDeleted = nil
    }

    func addNewStory() {
        store?.dispatch(.storyCard(.newStory))
    }

    func readStory(_ card: CardViewModel) {
        guard let card = card as? StoryCardViewModel else { return }
        store?.dispatch(.storyCard(.readStory(card)))
    }

    func showDeletePrompt(for card: CardViewModel) {
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteStory()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let alertViewModel = AlertViewModel(title: "Are you sure you want to delete \(card.title)?",
                                            message: "Are you sure you want to delete this story? This action will delete all of the illustrations, text, and audio recorded for this story.",
                                            actions: [deleteAction, cancelAction])
        AppLifeCycleManager.shared.router.route(to: .alert(alertViewModel, nil))
    }

    func deleteStory() {
        guard let toBeDeleted = toBeDeleted,
              let toBeDeleted = toBeDeleted as? StoryCardViewModel
        else {
            return
        }
        store?.dispatch(.storyCard(.deleteStory(toBeDeleted)))
        store?.dispatch(.storyCard(.exitDeleteMode))
        store?.dispatch(.storyCard(.updateStoryList))
    }

    func cancelDelete() {
        toBeDeleted = nil
        store?.dispatch(.storyCard(.exitDeleteMode))
    }

    func enterDeleteMode() {
        store?.dispatch(.storyCard(.enterDeleteMode))
    }

    func exitDeleteMode() {
        store?.dispatch(.storyCard(.enterDeleteMode))
    }
}
