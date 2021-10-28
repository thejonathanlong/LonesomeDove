//
//  DraftStoryManagedObject+CoreDataProperties.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/27/21.
//
//

import Foundation
import CoreData


extension DraftStoryManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DraftStoryManagedObject> {
        return NSFetchRequest<DraftStoryManagedObject>(entityName: "DraftStoryManagedObject")
    }

    @NSManaged public var title: String?
    @NSManaged public var date: Date?
    @NSManaged public var pages: PageManagedObject?
    @NSManaged public var author: AuthorManagedObject?

}

extension DraftStoryManagedObject : Identifiable {

}
