//
//  DataFetchingController.swift
//  LonesomeDove
//
//  Created by Jonathan Long on 1/3/22.
//

import CoreData

class DataFetchingController<ManagedObject: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    let resultsController: NSFetchedResultsController<ManagedObject>
    
    var fetchRequest: NSFetchRequest<ManagedObject>
        
    init(fetchRequest: NSFetchRequest<ManagedObject>, context: NSManagedObjectContext) {
        self.fetchRequest = fetchRequest
        resultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                       managedObjectContext: context,
                                                       sectionNameKeyPath: nil,
                                                       cacheName: nil)
        super.init()
        fetchRequest.fetchBatchSize = 10
    }
    
    func fetch() async throws -> [ManagedObject] {
        try resultsController.performFetch()
        return resultsController.fetchedObjects ?? []
        
    }
}
