//
//  CoreDataManager.swift
//  MyFitnes
//
//  Created by UMC on 2023/02/02.
//

import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyFitnes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
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
    
    func fetch<T: NSManagedObject>(entity: T.Type) -> [T] {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entity))
        do {
            let objects = try context.fetch(fetchRequest)
            return objects
        } catch let error as NSError {
            print("Error fetching objects: \(error), \(error.userInfo)")
            return []
        }
    }
    
    func fetch<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>) -> [T] {
        let context = persistentContainer.viewContext
        do {
            let objects = try context.fetch(fetchRequest)
            return objects
        } catch let error as NSError {
            print("Error fetching objects: \(error), \(error.userInfo)")
            return []
        }
    }
    
    func create<T: NSManagedObject>(entity: T.Type) -> T {
        let context = persistentContainer.viewContext
        let newObject = NSEntityDescription.insertNewObject(forEntityName: String(describing: entity), into: context) as! T
        return newObject
    }
    
    func delete<T: NSManagedObject>(object: T) {
        let context = persistentContainer.viewContext
        context.delete(object)
        saveContext()
    }
    
    func update<T: NSManagedObject>(object: T) {
        saveContext()
    }
}
