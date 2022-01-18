//
//  PageManagedObject+CoreDataProperties.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 1/17/22.
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
    @NSManaged public var posterImage: Data?
    @NSManaged public var draftStory: DraftStoryManagedObject?

    static var entityName: String {
        "PageManagedObject"
    }

    convenience init?(managedObjectContext: NSManagedObjectContext,
                      audioLastPathComponents: [String],
                      illustration: Data?,
                      number: Int16,
                      posterImage: Data?,
                      text: String?) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: PageManagedObject.entityName, in: managedObjectContext) else {
            return nil
        }

        self.init(entity: entityDescription, insertInto: managedObjectContext)

        self.audioLastPathComponents = audioLastPathComponents as NSArray
        self.illustration = illustration
        self.number = number
        self.text = text
        self.posterImage = posterImage
    }

}

extension PageManagedObject: Identifiable {

}
