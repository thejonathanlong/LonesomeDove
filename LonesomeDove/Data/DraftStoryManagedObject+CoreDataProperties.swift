//
//  DraftStoryManagedObject+CoreDataProperties.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 1/3/22.
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

extension DraftStoryManagedObject : Identifiable {

}
