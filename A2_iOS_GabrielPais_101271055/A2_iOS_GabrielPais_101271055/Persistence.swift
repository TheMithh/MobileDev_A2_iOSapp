import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Make sure this matches your actual .xcdatamodeld file name
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
                
                /*
                Common Core Data loading errors:
                - Model mismatch: The model doesn't match what's in the persistent store
                - File permission issues: The app can't access the store file
                - Store migration issues: Failed migration between versions
                */
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            print("Successfully loaded persistent store: \(storeDescription)")
        }
        
        // Configure context behavior for better performance and safety
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
