//
//  Persistence.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FeetTogetherModel")  // Updated model name
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // Save a training session to Core Data
    func saveSession(_ session: TrainingSession) {
        let context = container.viewContext
        let sessionEntity = TrainingSessionEntity(context: context)
        sessionEntity.id = session.id
        sessionEntity.name = session.name
        sessionEntity.timeBetweenTechniques = Int32(session.timeBetweenTechniques)
        sessionEntity.isFeetTogetherEnabled = session.isFeetTogetherEnabled
        sessionEntity.randomizeTechniques = session.randomizeTechniques

        // Add techniques, exercises, katas
        sessionEntity.selectedTechniques = NSSet(array: session.techniques.map { technique -> TechniqueEntity in
            let techniqueEntity = TechniqueEntity(context: context)
            techniqueEntity.id = technique.id
            techniqueEntity.name = technique.name
            techniqueEntity.category = technique.category
            return techniqueEntity
        })

        // Update to use selectedExercises instead of exercises
        sessionEntity.selectedExercises = NSSet(array: session.exercises.map { exercise -> ExerciseEntity in
            let exerciseEntity = ExerciseEntity(context: context)
            exerciseEntity.id = exercise.id
            exerciseEntity.name = exercise.name
            exerciseEntity.category = exercise.category
            return exerciseEntity
        })

        sessionEntity.selectedKatas = NSSet(array: session.katas.map { kata -> KataEntity in
            let kataEntity = KataEntity(context: context)
            kataEntity.id = kata.id
            kataEntity.name = kata.name
            kataEntity.category = kata.category
            return kataEntity
        })

        do {
            try context.save()
        } catch {
            fatalError("Failed to save session: \(error)")
        }
    }


    // Fetch all training sessions from Core Data
    func fetchAllSessions() -> [TrainingSession] {
        let request: NSFetchRequest<TrainingSessionEntity> = TrainingSessionEntity.fetchRequest()
        do {
            let sessionEntities = try container.viewContext.fetch(request)
            return sessionEntities.map { sessionEntity in
                // Extract techniques, exercises, and katas from Core Data entities
                let techniques = (sessionEntity.selectedTechniques?.allObjects as? [TechniqueEntity])?.map { techniqueEntity in
                    Technique(name: techniqueEntity.name ?? "", category: techniqueEntity.category ?? "")
                } ?? []

                let exercises = (sessionEntity.selectedExercises?.allObjects as? [ExerciseEntity])?.map { exerciseEntity in
                    Exercise(from: exerciseEntity)
                } ?? []

                let katas = (sessionEntity.selectedKatas?.allObjects as? [KataEntity])?.map { kataEntity in
                    Kata(from: kataEntity)
                } ?? []

                // Initialize and return TrainingSession
                return TrainingSession(
                    id: sessionEntity.id ?? UUID(),
                    name: sessionEntity.name ?? "Unnamed Session",
                    techniques: techniques,
                    exercises: exercises,
                    katas: katas,
                    timeBetweenTechniques: Int(sessionEntity.timeBetweenTechniques),
                    isFeetTogetherEnabled: sessionEntity.isFeetTogetherEnabled,
                    randomizeTechniques: sessionEntity.randomizeTechniques
                )
            }
        } catch {
            print("Error fetching training sessions: \(error)")
            return []
        }
    }
}
