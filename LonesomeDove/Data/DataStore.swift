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
    case addDraft(String, [Page], [StickerDisplayable])
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
    func deleteStory(named: String)
    @discardableResult func addDraft(named: String,
                                     pages: [Page],
                                     stickers: [StickerDisplayable]) -> DraftStoryManagedObject?
    func deleteDraft(named: String)
    @discardableResult func addSticker(drawingData: Data, imageData: Data?, creationDate: Date) -> StickerManagedObject?
    func fetchDraftsAndStories() async -> [StoryCardViewModel]
    func fetchPages(for story: StoryCardViewModel) async -> [Page]
    func fetchStickers() async -> [Sticker]
    func updateDraft(named: String,
                     newName: String?,
                     pages: [Page]) async
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
    
    func deleteStory(named: String) {
        let fetchRequest = StoryManagedObject.fetchRequest()
        delete(fetchRequest: fetchRequest, name: named)
    }

    @discardableResult func addDraft(named: String, pages: [Page], stickers: [StickerDisplayable]) -> DraftStoryManagedObject? {
        let pageManagedObjects = add(pages: pages)
        let duration = pages.reduce(0) {
            $0 + $1.duration
        }
        
        let stickerManagedObjects = stickers.compactMap {
            addSticker(drawingData: $0.stickerData, imageData: $0.stickerImage?.pngData(), creationDate: $0.creationDate)
        }
        
        let draft = DraftStoryManagedObject(managedObjectContext: persistentContainer.viewContext,
                                            date: Date(),
                                            title: named,
                                            duration: duration,
                                            pages: pageManagedObjects,
                                            stickers: stickerManagedObjects)

        pageManagedObjects.forEach {
            $0.draftStory = draft
        }
        
        stickerManagedObjects.forEach {
            $0.draft = draft
        }

        return draft
    }
    
    func deleteDraft(named: String) {
        let fetchRequest = DraftStoryManagedObject.fetchRequest()
        delete(fetchRequest: fetchRequest, name: named)
    }
    
    func addSticker(drawingData: Data, imageData: Data?, creationDate: Date) -> StickerManagedObject? {
        StickerManagedObject(managedObjectContext: persistentContainer.viewContext,
                             drawingData: drawingData,
                             imageData: imageData,
                             creationDate: creationDate)
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
            let pageManagedObjects = try await fetchPagesFor(storyName: story.title)
            return pageManagedObjects.compactMap { Page(pageManagedObject: $0) }
        } catch let error {
            delegate?.failed(with: error)
            return []
        }
    }
    
    func fetchStickers() async -> [Sticker] {
        do {
            let fetchRequest = StickerManagedObject.fetchRequest()
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: true)
            ]
            
            let fetchingController = DataFetchingController(fetchRequest: fetchRequest, context: persistentContainer.viewContext)
            let managedObjects = try await fetchingController.fetch()
            return managedObjects.compactMap {
                Sticker(sticker: $0)
            }
        } catch let error {
            delegate?.failed(with: error)
            return []
        }
    }
    
    func fetchStickers(for pageIndex: Int, storyName: String) async -> [Sticker] {
        
        do {
            let fetchRequest = StickerManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "draft.title == %@ AND page.index == %@", storyName, pageIndex)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: true)
            ]
            let dataFetchingController = DataFetchingController(fetchRequest: fetchRequest, context: persistentContainer.viewContext)
            let stickerManagedObjects = try await dataFetchingController.fetch()
            return stickerManagedObjects.compactMap { Sticker(sticker: $0) }
        } catch let error {
            delegate?.failed(with: error)
            return []
        }
    }
    
    func updateDraft(named: String, newName: String?, pages: [Page]) async {
        do {
            let pageManagedObjects = try await fetchPagesFor(storyName: named)
            let draftManagedObject = await fetchDraft(named: named)

            var sortedPages = pages.sorted { $0.index < $1.index }
            let lastPageNumber = pageManagedObjects.count
            let partition = sortedPages.partition { $0.index < lastPageNumber }
            let pagesNeedingUpdates = Array(sortedPages[..<partition])
            let pagesNeedingAddition = Array(sortedPages[partition...])

            zip(pageManagedObjects, pagesNeedingUpdates)
                .forEach {
                    update(page: $0.0, with: $0.1)
                }

            let newPageManagedObjects = add(pages: pagesNeedingAddition)
            let pmoSetToAdd = NSSet(array: newPageManagedObjects)
            
            draftManagedObject?.title = newName ?? named
            draftManagedObject?.addToPages(pmoSetToAdd)

        } catch let error {
            delegate?.failed(with: error)
        }
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

    private func fetchDraft(named name: String) async -> DraftStoryManagedObject? {
        do {
            let fetchRequest = DraftStoryManagedObject.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@", name as NSString)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "title", ascending: true)
            ]
            let dataFetchingController = DataFetchingController(fetchRequest: fetchRequest, context: persistentContainer.viewContext)
            let draftManagedObjects = try await dataFetchingController.fetch()
            return draftManagedObjects.first(where: {
                $0.title == name
            })
        } catch let error {
            delegate?.failed(with: error)
            return nil
        }
    }

    func fetchPagesFor(storyName: String) async throws -> [PageManagedObject] {
        let fetchRequest = PageManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "draftStory.title == %@", storyName as NSString)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "number", ascending: true)
        ]
        let dataFetchingController = DataFetchingController(fetchRequest: fetchRequest, context: persistentContainer.viewContext)
        return  try await dataFetchingController.fetch()
    }

    func update(page: PageManagedObject, with otherPage: Page) {
        page.audioLastPathComponents = otherPage
            .recordingURLs
            .compactMap { $0 }
            .map { $0.lastPathComponent } as NSArray
        page.illustration = otherPage.drawing.dataRepresentation()
        page.posterImage = otherPage.image?.pngData()
        updateStickers(oldPage: page, newPage: otherPage)
    }
    
    func updateStickers(oldPage: PageManagedObject, newPage: Page) {
        guard let oldStickers = oldPage.stickers as? Set<StickerManagedObject> else { return }
        let newStickers = newPage.stickers
        
        // There should really be a creation date...
        let oldStickersSorted = oldStickers.sorted { ($0.creationDate ?? Date()) < ($1.creationDate ?? Date()) }
        var newStickersSorted = newStickers.sorted { $0.creationDate < $1.creationDate }
        if newStickersSorted.count > oldStickersSorted.count {
            // There should really be a creation date...
            let partition = newStickersSorted.partition { $0.creationDate < (oldStickersSorted[oldStickersSorted.count].creationDate ?? Date()) }
            let stickersNeedingAddition = Array(newStickersSorted[partition...])
            
            stickersNeedingAddition.map {
                addSticker(drawingData: $0.stickerData, imageData: $0.stickerImage?.pngData(), creationDate: $0.creationDate)
            }.compactMap { $0 }
            .forEach { oldPage.addToStickers($0) }
        }
    }

    @discardableResult func add(pages: [Page]) -> [PageManagedObject] {
        pages
            .map {
                PageManagedObject(managedObjectContext: persistentContainer.viewContext,
                                  audioLastPathComponents: $0.recordingURLs.map {url in url?.lastPathComponent }.compactMap { $0 },
                                  illustration: $0.drawing.dataRepresentation(),
                                  number: Int16($0.index),
                                  posterImage: $0.image?.pngData(),
                                  text: "",
                                  stickers: [])
            }
            .compactMap { $0 }
    }
}

// MARK: - DataStoreError
enum DataStoreError: Error {
    case failedToCreateEntity
}
