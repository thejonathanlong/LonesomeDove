//
//  PageTextManagedObject+CoreDataProperties.swift
//  LonesomeDove
//
//  Created on 3/31/22.
//
//

import CoreData
import CoreGraphics
import Foundation

extension PageTextManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PageTextManagedObject> {
        return NSFetchRequest<PageTextManagedObject>(entityName: entityName)
    }

    @NSManaged public var text: String?
    @NSManaged public var type: String?
    @NSManaged public var page: PageManagedObject?
    @NSManaged public var position: String?
    
    static var entityName: String {
        "PageTextManagedObject"
    }

    convenience init?(managedObjectContext: NSManagedObjectContext,
                      text: String,
                      type: PageText.TextType,
                      page: PageManagedObject?,
                      position: CGPoint?) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: PageTextManagedObject.entityName, in: managedObjectContext) else {
            return nil
        }
        self.init(entity: entityDescription, insertInto: managedObjectContext)
        self.text = text
        self.type = type.rawValue
        self.page = page
        if let position = position {
            self.position =  NSCoder.string(for: position)
        }
        
    }
}

extension PageTextManagedObject : Identifiable {

}
