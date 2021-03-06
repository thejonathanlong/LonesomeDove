//
//  StickerManagedObject+CoreDataProperties.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 2/16/22.
//
//

import CoreGraphics
import Foundation
import CoreData

extension StickerManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StickerManagedObject> {
        return NSFetchRequest<StickerManagedObject>(entityName: "StickerManagedObject")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var drawingData: Data?
    @NSManaged public var imageData: Data?
    @NSManaged public var position: String?
    @NSManaged public var pageIndex: NSNumber?
    @NSManaged public var page: PageManagedObject?
    @NSManaged public var id: UUID?
    @NSManaged public var dateAdded: Date?
    @NSManaged public var draft: DraftStoryManagedObject?

    private static var entityName = "StickerManagedObject"

    convenience init?(managedObjectContext: NSManagedObjectContext,
                      drawingData: Data?,
                      imageData: Data?,
                      creationDate: Date?,
                      position: CGPoint,
                      id: UUID?,
                      dateAdded: Date?,
                      pageIndex: NSNumber?) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: StickerManagedObject.entityName, in: managedObjectContext) else {
            return nil
        }
        self.init(entity: entityDescription, insertInto: managedObjectContext)
        self.creationDate = creationDate
        self.drawingData = drawingData
        self.imageData = imageData
        self.page = nil
        self.draft = nil
        self.id = id
        self.dateAdded = dateAdded
        self.position = NSCoder.string(for: position)
        self.pageIndex = pageIndex
    }

}

extension StickerManagedObject: Identifiable {

}
