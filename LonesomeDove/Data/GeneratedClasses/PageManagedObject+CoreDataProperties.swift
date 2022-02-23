//
//  PageManagedObject+CoreDataProperties.swift
//  LonesomeDove
//
//  Created on 2/16/22.
//
//

import Foundation
import CoreData

extension PageManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PageManagedObject> {
        return NSFetchRequest<PageManagedObject>(entityName: "PageManagedObject")
    }

    @NSManaged public var audioLastPathComponents: NSArray?
    @NSManaged public var illustration: Data?
    @NSManaged public var number: Int16
    @NSManaged public var posterImage: Data?
    @NSManaged public var text: String?
    @NSManaged public var draftStory: DraftStoryManagedObject?
    @NSManaged public var stickers: NSSet?

    static var entityName: String {
        "PageManagedObject"
    }

    convenience init?(managedObjectContext: NSManagedObjectContext,
                      audioLastPathComponents: [String],
                      illustration: Data?,
                      number: Int16,
                      posterImage: Data?,
                      text: String?,
                      stickers: [StickerManagedObject]) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: PageManagedObject.entityName, in: managedObjectContext) else {
            return nil
        }

        self.init(entity: entityDescription, insertInto: managedObjectContext)

        self.audioLastPathComponents = audioLastPathComponents as NSArray
        self.illustration = illustration
        self.number = number
        self.text = text
        self.posterImage = posterImage
        self.stickers = NSSet(array: stickers)
    }

}

// MARK: Generated accessors for stickers
extension PageManagedObject {

    @objc(addStickersObject:)
    @NSManaged public func addToStickers(_ value: StickerManagedObject)

    @objc(removeStickersObject:)
    @NSManaged public func removeFromStickers(_ value: StickerManagedObject)

    @objc(addStickers:)
    @NSManaged public func addToStickers(_ values: NSSet)

    @objc(removeStickers:)
    @NSManaged public func removeFromStickers(_ values: NSSet)

}

extension PageManagedObject: Identifiable {

}
