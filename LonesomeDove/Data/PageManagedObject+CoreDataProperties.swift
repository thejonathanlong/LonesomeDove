//
//  PageManagedObject+CoreDataProperties.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 1/13/22.
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
    @NSManaged public var text: String?
    @NSManaged public var draftStory: DraftStoryManagedObject?

}

extension PageManagedObject: Identifiable {

}
