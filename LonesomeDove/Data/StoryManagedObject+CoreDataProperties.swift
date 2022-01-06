//
//  StoryManagedObject+CoreDataProperties.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 1/5/22.
//
//

import Foundation
import CoreData


extension StoryManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoryManagedObject> {
        return NSFetchRequest<StoryManagedObject>(entityName: "StoryManagedObject")
    }

    @NSManaged public var date: Date?
    @NSManaged public var duration: Double
    @NSManaged public var lastPathComponent: String?
    @NSManaged public var numberOfPages: Int16
    @NSManaged public var title: String?
    @NSManaged public var author: AuthorManagedObject?

}
