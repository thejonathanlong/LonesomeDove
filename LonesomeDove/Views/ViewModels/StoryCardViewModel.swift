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

class StoryCardViewModel: StoryCardDisplayable, CustomStringConvertible {
    var placeHolderPosterImage = UIImage(named: "placeholder") ?? UIImage()
    
    var title: String

    var timeStamp: String

    var duration: TimeInterval

    var numberOfPages: Int

    @Published var posterImage: UIImage?

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
        self.timeStamp = "\(duration)"
        self.duration = duration
        self.numberOfPages = numberOfPages
        self.posterImage = image ?? UIImage()
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

        self.title = title

        self.duration = managedObject.duration
        
        let time = Int(duration)
        let minutes = time / 60
        let seconds = time - (60 * minutes)
        
        self.timeStamp = "\(minutes):\(seconds > 10 ? "\(seconds)" : "0" + "\(seconds)")"
        self.numberOfPages = Int(managedObject.numberOfPages)
        self.posterImage = nil
        self.storyURL = locationURL
        self.isFavorite = false
        self.type = .finished
        self.date = managedObject.date ?? Date()
        
        movie.loadMetadata(for: AVMetadataFormat.quickTimeMetadata) { [weak self] newMeta, error in
            guard let self = self,
                let newMeta = newMeta else { return }
            
            let posterImageMetadata = AVMetadataItem.metadataItems(from: newMeta, filteredByIdentifier: StoryTimeMediaIdentifiers.posterImageMetadataIdentifier.metadataIdentifier).first
            let image = UIImage(data: posterImageMetadata?.dataValue ?? Data())
            DispatchQueue.main.async {
                self.posterImage = image
            }
        }
    }

    init?(managedObject: DraftStoryManagedObject) {
        guard let title = managedObject.title,
              let pageManagedObjects = managedObject.pages as? Set<PageManagedObject>
        else { return nil }

        let firstPage = pageManagedObjects.first { $0.number == 0 }
        if let data = firstPage?.posterImage,
           let image = UIImage(data: data) {
            self.posterImage = image
        } else {
            self.posterImage = UIImage()
        }

        self.title = title
        self.duration = managedObject.duration
        self.timeStamp = "\(managedObject.duration)"
        self.numberOfPages = pageManagedObjects.count
        self.isFavorite = false
        self.type = .draft
        self.storyURL = nil
        self.date = managedObject.date ?? Date()
    }

    func toggleFavorite() {

    }

    var description: String {
        "{\(title), \(date), \(duration)}"
    }
}

// MARK: - Hashable, Equatable
extension StoryCardViewModel: Hashable {
    static func == (lhs: StoryCardViewModel, rhs: StoryCardViewModel) -> Bool {
        lhs.title == rhs.title &&
        lhs.numberOfPages == rhs.numberOfPages &&
        lhs.timeStamp == rhs.timeStamp
    }

    func hash(into hasher: inout Hasher) {
        title.hash(into: &hasher)
        storyURL?.lastPathComponent.hash(into: &hasher)
        date.hash(into: &hasher)
        timeStamp.hash(into: &hasher)
    }
}
