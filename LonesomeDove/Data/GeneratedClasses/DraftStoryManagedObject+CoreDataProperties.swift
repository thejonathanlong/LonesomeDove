//
//  DraftStoryManagedObject+CoreDataProperties.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 2/16/22.
//
//

import Foundation
import CoreData

extension DraftStoryManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DraftStoryManagedObject> {
        return NSFetchRequest<DraftStoryManagedObject>(entityName: "DraftStoryManagedObject")
    }

    @NSManaged public var date: Date?
    @NSManaged public var duration: Double
    @NSManaged public var title: String?
    @NSManaged public var author: AuthorManagedObject?
    @NSManaged public var pages: NSSet?
    @NSManaged public var stickers: NSSet?

    private static var entityName: String {
        "DraftStoryManagedObject"
    }

    convenience init?(managedObjectContext: NSManagedObjectContext,
                      date: Date?,
                      title: String?,
                      duration: Double,
                      pages: [PageManagedObject],
                      stickers: [StickerManagedObject],
                      author: AuthorManagedObject? = nil) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: DraftStoryManagedObject.entityName, in: managedObjectContext) else {
            return nil
        }
        self.init(entity: entityDescription, insertInto: managedObjectContext)

        self.date = date
        self.title = title
        self.author = author
        self.pages = NSSet(array: pages)
        self.duration = duration
        self.stickers = NSSet(array: stickers)
    }

}

// MARK: Generated accessors for pages
extension DraftStoryManagedObject {

    @objc(addPagesObject:)
    @NSManaged public func addToPages(_ value: PageManagedObject)

    @objc(removePagesObject:)
    @NSManaged public func removeFromPages(_ value: PageManagedObject)

    @objc(addPages:)
    @NSManaged public func addToPages(_ values: NSSet)

    @objc(removePages:)
    @NSManaged public func removeFromPages(_ values: NSSet)

}

// MARK: Generated accessors for stickers
extension DraftStoryManagedObject {

    @objc(addStickersObject:)
    @NSManaged public func addToStickers(_ value: StickerManagedObject)

    @objc(removeStickersObject:)
    @NSManaged public func removeFromStickers(_ value: StickerManagedObject)

    @objc(addStickers:)
    @NSManaged public func addToStickers(_ values: NSSet)

    @objc(removeStickers:)
    @NSManaged public func removeFromStickers(_ values: NSSet)

}

extension DraftStoryManagedObject: Identifiable {

}
