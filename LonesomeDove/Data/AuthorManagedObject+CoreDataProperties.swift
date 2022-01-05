//
//  AuthorManagedObject+CoreDataProperties.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 1/3/22.
//
//

import Foundation
import CoreData


extension AuthorManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthorManagedObject> {
        return NSFetchRequest<AuthorManagedObject>(entityName: "AuthorManagedObject")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var drafts: NSSet?
    @NSManaged public var stories: NSSet?

}

// MARK: Generated accessors for drafts
extension AuthorManagedObject {

    @objc(addDraftsObject:)
    @NSManaged public func addToDrafts(_ value: DraftStoryManagedObject)

    @objc(removeDraftsObject:)
    @NSManaged public func removeFromDrafts(_ value: DraftStoryManagedObject)

    @objc(addDrafts:)
    @NSManaged public func addToDrafts(_ values: NSSet)

    @objc(removeDrafts:)
    @NSManaged public func removeFromDrafts(_ values: NSSet)

}

// MARK: Generated accessors for stories
extension AuthorManagedObject {

    @objc(addStoriesObject:)
    @NSManaged public func addToStories(_ value: StoryManagedObject)

    @objc(removeStoriesObject:)
    @NSManaged public func removeFromStories(_ value: StoryManagedObject)

    @objc(addStories:)
    @NSManaged public func addToStories(_ values: NSSet)

    @objc(removeStories:)
    @NSManaged public func removeFromStories(_ values: NSSet)

}

extension AuthorManagedObject : Identifiable {

}
