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
    var isKatasFetched: Bool = false

    // Cached data to avoid redundant fetching
    var cachedTechniques: [TechniqueEntity] = []
    var cachedExercises: [ExerciseEntity] = []
    var cachedKatas: [KataEntity] = []

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

    // Helper function to create a new KataEntity
    func createKata(context: NSManagedObjectContext, name: String, timestamp: Date = Date()) -> KataEntity {
        let newKata = KataEntity(context: context)
        newKata.id = UUID()  // Assign a new UUID to the id field
        newKata.name = name
        newKata.timestamp = timestamp
        return newKata
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
        let fetchRequest: NSFetchRequest<ExerciseEntity> = ExerciseEntity.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching selected exercises: \(error)")
            return []
        }
    }

    // Fetch all katas that are marked as selected
    func fetchSelectedKatas(context: NSManagedObjectContext) -> [KataEntity] {
        let fetchRequest: NSFetchRequest<KataEntity> = KataEntity.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching selected katas: \(error)")
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

    // Initialize selected katas with a guard to prevent redundant initialization
    func initializeSelectedKatas(context: NSManagedObjectContext) {
        let selectedKatas = fetchSelectedKatas(context: context)

        // Convert the fetched katas into the expected format (e.g., a dictionary or array)
        var katasDictionary: [String: Bool] = [:]
        for kata in selectedKatas {
            if let kataName = kata.name {
                katasDictionary[kataName] = true
            }
        }

        print("Initializing selected katas from session: \(katasDictionary)")
    }
    // Add this to CoreDataHelper.swift
    func fetchTrainingSessions(context: NSManagedObjectContext) -> [TrainingSession] {
        let fetchRequest: NSFetchRequest<TrainingSessionEntity> = TrainingSessionEntity.fetchRequest()

        do {
            let fetchedSessions = try context.fetch(fetchRequest)
            return fetchedSessions.map { sessionEntity in
                return convertEntityToTrainingSession(sessionEntity)
            }
        } catch {
            print("Error fetching training sessions: \(error)")
            return []
        }
    }

    // Helper function to convert a Core Data entity to TrainingSession
    private func convertEntityToTrainingSession(_ entity: TrainingSessionEntity) -> TrainingSession {
        let sections = entity.sections?.compactMap { sectionEntity in
            convertSectionEntityToTrainingSection(sectionEntity as! TrainingSectionEntity)
        } ?? []

        return TrainingSession(
            name: entity.name ?? "Unknown",
            timeBetweenTechniques: Int(entity.timeBetweenTechniques),
            isFeetTogetherEnabled: entity.isFeetTogetherEnabled,
            randomizeTechniques: entity.randomizeTechniques,
            sections: sections
        )
    }

    // Helper function to convert Core Data section entities into TrainingSection
    private func convertSectionEntityToTrainingSection(_ entity: TrainingSectionEntity) -> TrainingSection {
        let items = entity.items?.compactMap { itemEntity in
            convertItemEntityToAnyTrainingItem(itemEntity as! TrainingItemEntity)
        } ?? []

        return TrainingSection(
            id: entity.id ?? UUID(),
            type: SectionType(rawValue: entity.type ?? "Unknown") ?? .technique,
            items: items
        )
    }

    // Helper function to convert Core Data training item entities into AnyTrainingItem
    private func convertItemEntityToAnyTrainingItem(_ entity: TrainingItemEntity) -> AnyTrainingItem {
        return AnyTrainingItem(
            id: entity.id ?? UUID(),
            name: entity.name ?? "Unknown",
            category: entity.category ?? "Unknown"
        )
    }

}
