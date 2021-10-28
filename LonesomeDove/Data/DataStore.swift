//
//  DataStore.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 10/26/21.
//

import Foundation
import CoreData

protocol DataStorable {
    var delegate: DataStoreDelegate? { get set }
    func save()
}

protocol DataStoreDelegate: AnyObject {
    func failed(with error: Error)
}

//MARK: - DataStore
class DataStore {
    weak var delegate: DataStoreDelegate?
    
    init(delegate: DataStoreDelegate? = nil) {
        self.delegate = delegate
    }
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "LonesomeDove")
        container.loadPersistentStores(completionHandler: {[weak self] (storeDescription, error) in
            if let error = error as NSError? {
                self?.delegate?.failed(with: error)
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}

//MARK: - DataStorable
extension DataStore: DataStorable {
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                self.delegate?.failed(with: error)
                fatalError("Unresolved error \((error as NSError)), \((error as NSError).userInfo)")
            }
        }
    }
}
