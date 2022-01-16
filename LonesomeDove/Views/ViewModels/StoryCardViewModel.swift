//
//  StoryCardViewModel.swift
//  LonesomeDove
//  Created on 10/22/21.
//

import AVFoundation
import UIKit

class StoryCardViewModel: StoryCardDisplayable {
    
    enum StoryType {
        case draft, finished
    }
    
    var title: String

    var duration: String

    var numberOfPages: Int

    var image: UIImage

    var isFavorite: Bool

    var id = UUID()

    var storyURL: URL
    
    var type: StoryType

    init(title: String,
         duration: TimeInterval,
         numberOfPages: Int,
         image: UIImage?,
         storyURL: URL,
         storyType: StoryType = .finished,
         isFavorite: Bool = false) {
        self.title = title
        self.duration = "\(duration)"
        self.numberOfPages = numberOfPages
        self.image = image ?? UIImage()
        self.isFavorite = isFavorite
        self.type = storyType
        self.storyURL = storyURL
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

    }

    func toggleFavorite() {

    }
}
