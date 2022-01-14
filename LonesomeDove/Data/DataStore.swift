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
        guard let storyEntityDescription = NSEntityDescription.entity(forEntityName: "StoryManagedObject", in: persistentContainer.viewContext) else {
            self.delegate?.failed(with: DataStoreError.failedToCreateEntity)
            return
        }
        let storyManagedObject = NSManagedObject(entity: storyEntityDescription, insertInto: persistentContainer.viewContext)
        storyManagedObject.setValue(named, forKey: "title")
        storyManagedObject.setValue(location.lastPathComponent, forKey: "lastPathComponent")
        storyManagedObject.setValue(duration, forKey: "duration")
        storyManagedObject.setValue(Date(), forKey: "date")
        storyManagedObject.setValue(numberOfPages, forKey: "numberOfPages")
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

enum DataStoreError: Error {
    case failedToCreateEntity
}
