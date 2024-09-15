//
//  CoreDataHelpers.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/14/24.
//

import CoreData

// Helper function to create a new TechniqueEntity
func createTechnique(context: NSManagedObjectContext, name: String, category: String, timestamp: Date = Date()) -> TechniqueEntity {
    let newTechnique = TechniqueEntity(context: context)
    newTechnique.id = UUID()  // Assign a new UUID to the id field
    newTechnique.name = name
    newTechnique.category = category
    newTechnique.timestamp = timestamp
    return newTechnique
}

// Helper function to create a new ExerciseEntity
func createExercise(context: NSManagedObjectContext, name: String, reps: Int16, timestamp: Date = Date()) -> ExerciseEntity {
    let newExercise = ExerciseEntity(context: context)  // Now using ExerciseEntity
    newExercise.name = name
    newExercise.reps = reps
    newExercise.timestamp = timestamp
    return newExercise
}

// Fetch all techniques that are marked as selected
func fetchSelectedTechniques(context: NSManagedObjectContext) -> [TechniqueEntity] {
    let fetchRequest: NSFetchRequest<TechniqueEntity> = TechniqueEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "isSelected == true")  // Fetch only selected techniques

    do {
        return try context.fetch(fetchRequest)
    } catch {
        print("Error fetching selected techniques: \(error)")
        return []
    }
}



func initializeSelectedTechniques(context: NSManagedObjectContext) {
    let selectedTechniques = fetchSelectedTechniques(context: context)

    // Convert the fetched techniques into the expected format (e.g., a dictionary or array)
    var techniquesDictionary: [String: Bool] = [:]
    for technique in selectedTechniques {
        if let techniqueName = technique.name {
            techniquesDictionary[techniqueName] = true
        }
    }
    
    print("Initializing selected techniques from session: \(techniquesDictionary)")
}
