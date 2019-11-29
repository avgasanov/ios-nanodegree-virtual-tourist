//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Abdulla Hasanov on 11/27/19.
//  Copyright © 2019 Abdulla Hasanov. All rights reserved.
//

import Foundation
import CoreData

// from udacity lessons: Mooskin app 
class DataController {
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores() { storeDesc, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
           completion?()
        }
    }
}
