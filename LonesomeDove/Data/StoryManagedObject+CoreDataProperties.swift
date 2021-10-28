//
//  StoryManagedObject+CoreDataProperties.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/27/21.
//
//

import Foundation
import CoreData


extension StoryManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoryManagedObject> {
        return NSFetchRequest<StoryManagedObject>(entityName: "StoryManagedObject")
    }

    @NSManaged public var title: String?
    @NSManaged public var date: Date?
    @NSManaged public var data: Data?
    @NSManaged public var pages: NSSet?
    @NSManaged public var author: AuthorManagedObject?

}

// MARK: Generated accessors for pages
extension StoryManagedObject {

    @objc(addPagesObject:)
    @NSManaged public func addToPages(_ value: PageManagedObject)

    @objc(removePagesObject:)
    @NSManaged public func removeFromPages(_ value: PageManagedObject)

    @objc(addPages:)
    @NSManaged public func addToPages(_ values: NSSet)

    @objc(removePages:)
    @NSManaged public func removeFromPages(_ values: NSSet)

}

extension StoryManagedObject : Identifiable {

}
