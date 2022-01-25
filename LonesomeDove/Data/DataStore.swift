//
//  DataStore.swift
//  LonesomeDove
//  Created on 10/26/21.
//

import AVFoundation
import CoreData
import Foundation

// MARK: DataStoreAction
enum DataStoreAction {
    case save
    case addStory(String, URL, TimeInterval, Int)
    case addDraft(String, [Page])
}

// MARK: - DataStorable
protocol DataStorable {
    var delegate: DataStoreDelegate? { get set }
    func save()
}

// MARK: - StoryDataStorable
protocol StoryDataStorable: DataStorable {
    @discardableResult func addStory(named: String,
                                     location: URL,
                                     duration: TimeInterval,
                                     numberOfPages: Int) -> StoryManagedObject?
    @discardableResult func addDraft(named: String,
                                     pages: [Page]) -> DraftStoryManagedObject?
    func fetchDraftsAndStories() async -> [StoryCardViewModel]
    func fetchPages(for story: StoryCardViewModel) async -> [Page]
    func deleteStory(named: String)
    func deleteDraft(named: String)
}

// MARK: - DataStoreDelegate
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
extension DataStore {
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
}

// MARK: - StoryDataStorable
extension DataStore: StoryDataStorable {
    @discardableResult func addStory(named: String, location: URL, duration: TimeInterval, numberOfPages: Int) -> StoryManagedObject? {
        StoryManagedObject(managedObjectContext: persistentContainer.viewContext,
                           title: named,
                           date: Date(),
                           duration: duration,
                           lastPathComponent: location.lastPathComponent,
                           numberOfPages: Int16(numberOfPages))
    }

    @discardableResult func addDraft(named: String, pages: [Page]) -> DraftStoryManagedObject? {
        let pageManagedObjects = pages
            .map {
                PageManagedObject(managedObjectContext: persistentContainer.viewContext,
                                  audioLastPathComponents: $0.recordingURLs.map {url in url?.lastPathComponent }.compactMap { $0 },
                                  illustration: $0.drawing.dataRepresentation(),
                                  number: Int16($0.index),
                                  posterImage: $0.image?.pngData(),
                                  text: "")
            }
            .compactMap { $0 }
        let duration = pages.reduce(0) {
            $0 + $1.duration
        }
        let draft = DraftStoryManagedObject(managedObjectContext: persistentContainer.viewContext,
                                            date: Date(),
                                            title: named,
                                            duration: duration,
                                            pages: pageManagedObjects)

        pageManagedObjects.forEach {
            $0.draftStory = draft
        }

        return draft
    }

    func fetchDraftsAndStories() async -> [StoryCardViewModel] {
        let stories = await fetchStories()
        let drafts = await fetchDrafts()
        let storiesAndDrafts = stories + drafts

        return storiesAndDrafts.sorted {
            $0.date > $1.date
        }
    }

    func fetchPages(for story: StoryCardViewModel) async -> [Page] {
        guard story.type == .draft else {
            return []
        }
        do {
            let fetchRequest = PageManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "draftStory.title == %@", story.title as NSString)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "number", ascending: true)
            ]
            let dataFetchingController = DataFetchingController(fetchRequest: fetchRequest, context: persistentContainer.viewContext)
            let pageManagedObjects = try await dataFetchingController.fetch()
            return pageManagedObjects.compactMap { Page(pageManagedObject: $0) }
        } catch let error {
            delegate?.failed(with: error)
            return []
        }
    }

    func deleteDraft(named: String) {
        let fetchRequest = DraftStoryManagedObject.fetchRequest()
        delete(fetchRequest: fetchRequest, name: named)
    }

    func deleteStory(named: String) {
        let fetchRequest = StoryManagedObject.fetchRequest()
        delete(fetchRequest: fetchRequest, name: named)
    }
}

// MARK: - Private
private extension DataStore {
    private func cleanupFiles(for object: NSManagedObject) throws {
        switch object {
            case let managedObject as StoryManagedObject:
                if let title = managedObject.title {
                    let storyURL = DataLocationModels.stories(title).URL()
                    if FileManager.default.fileExists(atPath: storyURL.path) {
                        try FileManager.default.removeItem(at: storyURL)
                    }
                }
            case let managedObject as DraftStoryManagedObject:
                try managedObject
                    .pages?
                    .compactMap { $0 as? PageManagedObject }
                    .map { $0.audioLastPathComponents as? [String] }
                    .compactMap { $0 }
                    .flatMap { $0 }
                    .forEach {
                        let containingURL = DataLocationModels.recordings(UUID()).containingDirectory()
                        try FileManager.default.removeItem(at: containingURL.appendingPathComponent($0))
                    }

            default:
                break
        }
    }

    private func delete<T>(fetchRequest: NSFetchRequest<T>, name: String) where T: NSManagedObject {
        fetchRequest.predicate = NSPredicate(format: "title == %@", name as NSString)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]

        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if let firstDraft = results.first {
                try cleanupFiles(for: firstDraft)
                persistentContainer.viewContext.delete(firstDraft)
            }
        } catch let e {
            delegate?.failed(with: e)
        }
    }

    private func fetchStories() async -> [StoryCardViewModel] {
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

    private func fetchDrafts() async -> [StoryCardViewModel] {
        do {
            let fetchRequest = DraftStoryManagedObject.fetchRequest()
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

// MARK: - DataStoreError
enum DataStoreError: Error {
    case failedToCreateEntity
}
