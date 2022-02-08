//
//  SavedDrawingManagedObject+CoreDataProperties.swift
//  LonesomeDove
//
//  Created on 2/6/22.
//
//

import Foundation
import CoreData


extension SavedDrawingManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedDrawingManagedObject> {
        return NSFetchRequest<SavedDrawingManagedObject>(entityName: "SavedDrawingManagedObject")
    }

    @NSManaged public var illustrationData: Data?
    @NSManaged public var creationDate: Date?
    
    private static var entityName = "SavedDrawingManagedObject"
    
    convenience init?(managedObjectContext: NSManagedObjectContext,
                      illustrationData: Data?,
                      creationDate: Date?) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: SavedDrawingManagedObject.entityName, in: managedObjectContext) else {
            return nil
        }
        self.init(entity: entityDescription, insertInto: managedObjectContext)
        self.creationDate = creationDate
        self.illustrationData = illustrationData
    }

}

extension SavedDrawingManagedObject : Identifiable {

}
