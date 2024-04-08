//
//  StorageManager.swift
//  TaskList
//
//  Created by Vladimir Dmitriev on 07.04.24.
//

import CoreData

final class StorageManager {
    
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private let viewContext: NSManagedObjectContext

    private init() {
        viewContext = persistentContainer.viewContext
    }
    
    // MARK: - CRUD
    func create(_ taskName: String, completion: (ToDoTask) -> Void) {
        let task = ToDoTask(context: viewContext)
        task.title = taskName
        completion(task)
        saveContext()
    }
    
    func fetchData(completion: (Result<[ToDoTask], Error>) -> Void) {
        let fetchRequest = ToDoTask.fetchRequest()
        
        do {
            let tasks = try viewContext.fetch(fetchRequest)
            completion(.success(tasks))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func update(_ task: ToDoTask, newName: String) {
        task.title = newName
        saveContext()
    }
    
    func delete(_ task: ToDoTask) {
        viewContext.delete(task)
        saveContext()
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
