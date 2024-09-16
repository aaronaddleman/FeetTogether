//
//  Feet_TogetherApp.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

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
    // Initialize the list of all techniques, exercises, and katas
    @State private var allTechniques: [Technique] = predefinedTechniques
    @State private var allExercises: [Exercise] = predefinedExercises  // Replace with your predefined exercises
    @State private var allKatas: [Kata] = predefinedKatas  // Replace with your predefined katas

    // Core Data persistent container
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FeetTogetherModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(
                allTechniques: $allTechniques,
                allExercises: $allExercises,
                allKatas: $allKatas
            ) // Pass the list of techniques, exercises, and katas to ContentView
            .environment(\.managedObjectContext, persistentContainer.viewContext) // Provide the managed object context
        }
    }
}

