//
//  DraftStoryManagedObject+CoreDataProperties.swift
//  LonesomeDove
//  Created on 1/3/22.
//
//

import Foundation
import CoreData

extension DraftStoryManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DraftStoryManagedObject> {
        return NSFetchRequest<DraftStoryManagedObject>(entityName: "DraftStoryManagedObject")
    }

    @NSManaged public var date: Date?
    @NSManaged public var title: String?
    @NSManaged public var author: AuthorManagedObject?
    @NSManaged public var pages: NSSet?

    private static var entityName: String {
        "DraftStoryManagedObject"
    }

    convenience init?(managedObjectContext: NSManagedObjectContext,
                      date: Date?,
                      title: String?,
                      pages: [PageManagedObject],
                      author: AuthorManagedObject? = nil) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: DraftStoryManagedObject.entityName, in: managedObjectContext) else {
            return nil
        }
        self.init(entity: entityDescription, insertInto: managedObjectContext)

        self.date = date
        self.title = title
        self.author = author
        self.pages = NSSet(array: pages)
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

extension DraftStoryManagedObject: Identifiable {

}
