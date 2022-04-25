//
//  StoryManagedObject+CoreDataProperties.swift
//  LonesomeDove
//  Created on 1/5/22.
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
    @NSManaged public var posterImage: Data?
    @NSManaged public var author: AuthorManagedObject?

    private static var entityName: String {
        "StoryManagedObject"
    }

    convenience init?(managedObjectContext: NSManagedObjectContext,
                      title: String?,
                      date: Date?,
                      duration: Double,
                      lastPathComponent: String?,
                      numberOfPages: Int16,
                      imageData: Data?,
                      author: AuthorManagedObject? = nil) {
        guard let entity = NSEntityDescription.entity(forEntityName: StoryManagedObject.entityName, in: managedObjectContext) else {
            return nil
        }

        self.init(entity: entity, insertInto: managedObjectContext)

        self.title = title
        self.date = date
        self.duration = duration
        self.lastPathComponent = lastPathComponent
        self.numberOfPages = numberOfPages
        self.author = author
        self.posterImage = imageData
    }
}
