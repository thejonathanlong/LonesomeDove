//
//  DataStore.swift
//  LonesomeDove
//  Created on 10/26/21.
//

import AVFoundation
import CoreData
import Foundation

enum DataStoreAction {
    case save
    case addStory(String, URL, TimeInterval, Int)
}

protocol DataStorable {
    var delegate: DataStoreDelegate? { get set }
    func save()
    func addStory(named: String,
                  location: URL,
                  duration: TimeInterval,
                  numberOfPages: Int)
    func addDraft(named: String, pages: [Page])
    func fetchStories() async -> [StoryCardViewModel]
}

protocol DataStoreDelegate: AnyObject {
    func failed(with error: Error)
}

// MARK: - DataStore
class DataStore {
    weak var delegate: DataStoreDelegate?

    init(delegate: DataStoreDelegate? = nil) {
        self.delegate = delegate
    }

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "LonesomeDove")
        container.loadPersistentStores(completionHandler: {[weak self] (_, error) in
            if let error = error as NSError? {
                self?.delegate?.failed(with: error)
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}

// MARK: - DataStorable
extension DataStore: DataStorable {
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                self.delegate?.failed(with: error)
                fatalError("Unresolved error \((error as NSError)), \((error as NSError).userInfo)")
            }
        }
    }

    func addStory(named: String, location: URL, duration: TimeInterval, numberOfPages: Int) {
        guard let storyEntityDescription = NSEntityDescription.entity(forEntityName: "StoryManagedObject", in: persistentContainer.viewContext),
              let storyManagedObject = NSManagedObject(entity: storyEntityDescription, insertInto: persistentContainer.viewContext) as? StoryManagedObject
        else {
            self.delegate?.failed(with: DataStoreError.failedToCreateEntity)
            return
        }

        storyManagedObject.title = named
        storyManagedObject.lastPathComponent = location.lastPathComponent
        storyManagedObject.duration = duration
        storyManagedObject.date = Date()
        storyManagedObject.numberOfPages = Int16(numberOfPages)

    }

    func addDraft(named: String, pages: [Page]) {
        guard let draftEntityDescription = NSEntityDescription.entity(forEntityName: "DraftStoryManagedObject", in: persistentContainer.viewContext),
              let draftStoryManagedObject = NSManagedObject(entity: draftEntityDescription, insertInto: persistentContainer.viewContext) as? DraftStoryManagedObject
        else {
            self.delegate?.failed(with: DataStoreError.failedToCreateEntity)
            return
        }

        draftStoryManagedObject.title = named
        draftStoryManagedObject.date = Date()

        pages.forEach {
            if let pageObject = pageObject(from: $0) {
                draftStoryManagedObject.addToPages(pageObject)
            }
        }
    }

    func fetchStories() async -> [StoryCardViewModel] {
        do {
            let fetchRequest = StoryManagedObject.fetchRequest()
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "date", ascending: false)
            ]
            let dataFetchingController = DataFetchingController(fetchRequest: fetchRequest, context: persistentContainer.viewContext)
            let storyManagedObjects = try await dataFetchingController.fetch()
            return storyManagedObjects.compactMap { StoryCardViewModel(managedObject: $0) }
        } catch let error {
            delegate?.failed(with: error)
            return []
        }
    }
}

// MARK: - Private
private extension DataStore {
    private func pageObject(from page: Page) -> PageManagedObject? {
        guard let pageEntityDscription = NSEntityDescription.entity(forEntityName: "PageManagedObject", in: persistentContainer.viewContext),
              let pageManagedObject = NSManagedObject(entity: pageEntityDscription, insertInto: persistentContainer.viewContext) as? PageManagedObject
        else {
            self.delegate?.failed(with: DataStoreError.failedToCreateEntity)
            return nil
        }

        pageManagedObject.number = Int16(page.index)
        pageManagedObject.illustration = page.drawing.dataRepresentation()
        pageManagedObject.audioLastPathComponents = page.recordingURLs.map { $0?.lastPathComponent } as NSArray

        return pageManagedObject
    }
}

// MARK: - DataStoreError
enum DataStoreError: Error {
    case failedToCreateEntity
}
