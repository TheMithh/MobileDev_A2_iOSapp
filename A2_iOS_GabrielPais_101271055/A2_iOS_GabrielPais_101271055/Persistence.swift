import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ProductModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Log more details about the error
                print("Failed to load Core Data stack: \(error)")
                print("Store description: \(storeDescription)")
                print("Error description: \(error.localizedDescription)")
                print("Error domain: \(error.domain), code: \(error.code)")
                print("Error user info: \(error.userInfo)")
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            print("Successfully loaded persistent store: \(storeDescription)")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // Helper method to save context
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Context saved successfully")
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
