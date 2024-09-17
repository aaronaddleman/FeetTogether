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
        let container = NSPersistentContainer(name: "FeetTogetherModel")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()  // No need to pass `allTechniques`, `allExercises`, or `allKatas`
                .environment(\.managedObjectContext, persistentContainer.viewContext) // Provide the managed object context
        }
    }
}
