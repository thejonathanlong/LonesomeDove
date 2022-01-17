//
//  StoryCardViewModel.swift
//  LonesomeDove
//  Created on 10/22/21.
//

import AVFoundation
import UIKit

enum StoryType {
    case draft, finished, add

    var description: String {
        switch self {
            case .draft:
                return "Draft"

            case .finished:
                return "Finished Story"

            case .add:
                return "Add"
        }
    }
}

class StoryCardViewModel: StoryCardDisplayable {
    var title: String

    var duration: String

    var numberOfPages: Int

    var image: UIImage

    var isFavorite: Bool

    var id = UUID()

    var storyURL: URL?

    var date: Date

    var type: StoryType

    init(title: String,
         duration: TimeInterval,
         numberOfPages: Int,
         image: UIImage?,
         storyURL: URL,
         date: Date = Date(),
         storyType: StoryType = .finished,
         isFavorite: Bool = false) {
        self.title = title
        self.duration = "\(duration)"
        self.numberOfPages = numberOfPages
        self.image = image ?? UIImage()
        self.isFavorite = isFavorite
        self.type = storyType
        self.storyURL = storyURL
        self.date = date
    }

    init?(managedObject: StoryManagedObject) {
        guard let title = managedObject.title,
              let lastPathComponent = managedObject.lastPathComponent
        else { return nil }

        let locationURL = DataLocationModels.stories(title).containingDirectory().appendingPathComponent(lastPathComponent)

        let movie = AVMovie(url: locationURL)
        let metadata = movie.metadata(forFormat: AVMetadataFormat.quickTimeMetadata)
        let posterImageMetadata = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: StoryTimeMediaIdentifiers.posterImageMetadataIdentifier.metadataIdentifier).first
        let image = UIImage(data: posterImageMetadata?.dataValue ?? Data())

        self.title = title

        self.duration = "\(managedObject.duration)"
        self.numberOfPages = Int(managedObject.numberOfPages)
        self.image = image ?? UIImage()
        self.storyURL = locationURL
        self.isFavorite = false
        self.type = .finished
        self.date = managedObject.date ?? Date()
    }

    init?(managedObject: DraftStoryManagedObject) {
        guard let title = managedObject.title,
              let pages = managedObject.pages as? Set<Page>
        else { return nil }

        self.title = title
        self.image = pages.first(where: {
            $0.index == 0
        })?.image ?? UIImage()
        let duration = pages.reduce(0) {
            $0 + $1.duration
        }
        self.duration = "\(duration)"
        self.numberOfPages = pages.count
        self.isFavorite = false
        self.type = .draft
        self.storyURL = nil
        self.date = managedObject.date ?? Date()
    }

    func toggleFavorite() {

    }
}

// MARK: - Hashable, Equatable
extension StoryCardViewModel: Hashable {
    static func == (lhs: StoryCardViewModel, rhs: StoryCardViewModel) -> Bool {
        lhs.title == rhs.title &&
        lhs.numberOfPages == rhs.numberOfPages &&
        lhs.duration == rhs.duration
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
        title.hash(into: &hasher)
        storyURL?.lastPathComponent.hash(into: &hasher)
        date.hash(into: &hasher)
        duration.hash(into: &hasher)
    }
}
