//
//  StickerManagedObject+CoreDataProperties.swift
//  LonesomeDove
//
//  Created on 2/15/22.
//
//

import Foundation
import CoreData


extension StickerManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StickerManagedObject> {
        return NSFetchRequest<StickerManagedObject>(entityName: "StickerManagedObject")
    }

    @NSManaged public var creationDate: Date?
    @NSManaged public var data: Data?
    
    private static var entityName = "StickerManagedObject"
    
    convenience init?(managedObjectContext: NSManagedObjectContext,
                      data: Data?,
                      creationDate: Date?) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: StickerManagedObject.entityName, in: managedObjectContext) else {
            return nil
        }
        self.init(entity: entityDescription, insertInto: managedObjectContext)
        self.creationDate = creationDate
        self.data = data
    }

}
