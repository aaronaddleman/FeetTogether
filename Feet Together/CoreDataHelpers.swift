//
//  CoreDataHelpers.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/14/24.
//

import CoreData

// A class to help manage CoreData fetches and avoid redundant fetching
class CoreDataHelper {
    static let shared = CoreDataHelper()

    // Flags to track if data has already been initialized to avoid redundant fetching
    var isTechniquesFetched: Bool = false
    var isExercisesFetched: Bool = false

    // Cached data to avoid redundant fetching
    var cachedTechniques: [TechniqueEntity] = []
    var cachedExercises: [ExerciseEntity] = []

    private init() {}

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
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching selected techniques: \(error)")
            return []
        }
    }
    
    // Fetch all exercises that are marked as selected
    func fetchSelectedExercises(context: NSManagedObjectContext) -> [ExerciseEntity] {
        guard !isExercisesFetched else {
            print("Exercises already fetched, returning cached data.")
            return cachedExercises
        }

        let fetchRequest: NSFetchRequest<ExerciseEntity> = ExerciseEntity.fetchRequest()
        // You can add a predicate here for filtering if necessary

        do {
            cachedExercises = try context.fetch(fetchRequest)
            isExercisesFetched = true // Mark that exercises have been fetched
            return cachedExercises
        } catch {
            print("Error fetching selected exercises: \(error)")
            return []
        }
    }

    // Initialize selected techniques with a guard to prevent redundant initialization
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
}
