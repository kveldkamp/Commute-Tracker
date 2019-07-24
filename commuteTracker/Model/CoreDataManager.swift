//
//  CoreDataManager.swift
//  commuteTracker
//
//  Created by Kevin Veldkamp on 7/23/19.
//  Copyright © 2019 kevin veldkamp. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    private init(){}
    
    class func getContext() -> NSManagedObjectContext {
        return CoreDataManager.persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "commuteTracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    class func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
    
    
    
}
