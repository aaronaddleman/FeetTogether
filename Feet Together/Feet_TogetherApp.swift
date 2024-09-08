//
//  Feet_TogetherApp.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import SwiftUI
import CoreData

@main
struct Feet_TogetherApp: App {
    
    // Core Data persistent container
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FeetTogetherModel") // Replace with your model name
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentContainer.viewContext) // Provide the managed object context
        }
    }
}
