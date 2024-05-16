//
//  CoreDataStack.swift
//  BudgetManager
//
//  Created by Jadson on 18/04/2024.
//

import Foundation
import CoreData
import ProgressHUD

class CoreDataStack {
    static let shared: CoreDataStack = .init()
    
    private init(){}
    
    lazy var container: NSPersistentContainer = {
        let p = NSPersistentContainer(name: "BudgetManagerModel")
        p.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return p
    }()
    
    //Computed property
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                ProgressHUD.failed()
                let nserror = error as NSError
                print(nserror)
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
