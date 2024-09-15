//
//  EditExerciseView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

//
//  EditExercisesView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI
import CoreData

struct EditExercisesView: View {
    @Binding var session: TrainingSession
    @Binding var allExercises: [Exercise]
    @State private var selectedExercises: [UUID: Bool] = [:]  // Track selected exercises by UUID
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        List {
            // Use allExercises to display available exercises
            ForEach(allExercises) { exercise in
                HStack {
                    Text(exercise.name)
                    Spacer()
                    Toggle("", isOn: toggleBinding(for: exercise))
                        .labelsHidden()
                }
            }
        }
        .toolbar {
            EditButton() // Enables drag-and-drop if necessary
        }
        .navigationTitle("Edit Exercises")
        .onAppear {
            loadSelectedExercises()  // Load exercises on appear
        }
        .onDisappear {
            saveSelectedExercises()  // Save exercises on disappear
        }
    }

    // Toggle Binding for Exercise Activation
    private func toggleBinding(for exercise: Exercise) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                selectedExercises[exercise.id] ?? false  // Use exercise.id as UUID
            },
            set: { newValue in
                selectedExercises[exercise.id] = newValue  // Update selection by UUID
            }
        )
    }

    // Save selected exercises to Core Data and session
    private func saveSelectedExercises() {
        print("Saving selected exercises...")
        
        for exercise in allExercises {
            let isSelected = selectedExercises[exercise.id] ?? false
            print("Exercise \(exercise.name) isSelected: \(isSelected)")
            
            // Fetch or create a corresponding ExerciseEntity in Core Data
            var exerciseEntity = fetchExerciseEntity(by: exercise.id, context: context)
            
            if exerciseEntity == nil {
                // Create a new ExerciseEntity if not found
                print("Creating new ExerciseEntity for id: \(exercise.id)")
                exerciseEntity = ExerciseEntity(context: context)
                exerciseEntity?.id = exercise.id
                exerciseEntity?.name = exercise.name
            }
            
            // Update the `isSelected` property
            exerciseEntity?.isSelected = isSelected
        }

        do {
            try context.save()  // Ensure the context is saved with updated selections
            print("Core Data context for exercises saved successfully.")
        } catch {
            print("Failed to save exercises in Core Data: \(error)")
        }

        // Update session's selectedExercises with UUIDs
        session.selectedExercises = selectedExercises
        print("Session's selectedExercises updated: \(session.selectedExercises)")
    }

    // Load selected exercises from Core Data and merge with session
    private func loadSelectedExercises() {
        print("Loading selected exercises from Core Data and session...")
        let fetchedSelectedExercises = fetchSelectedExercises(context: context)
        
        var exercisesDictionary: [UUID: Bool] = [:]
        for exerciseEntity in fetchedSelectedExercises {
            if let id = exerciseEntity.id {
                exercisesDictionary[id] = exerciseEntity.isSelected
                print("Loaded exercise from Core Data: \(exerciseEntity.name ?? "Unknown Name") isSelected: \(exerciseEntity.isSelected)")
            }
        }

        let initialSelectedExercises = session.selectedExercises
        for (uuid, selected) in initialSelectedExercises {
            exercisesDictionary[uuid] = selected
            print("Merging exercise from session: \(uuid) isSelected: \(selected)")
        }

        print("Final merged state of selected exercises: \(exercisesDictionary)")
        selectedExercises = exercisesDictionary
    }

    // Fetch ExerciseEntity from Core Data by UUID
    private func fetchExerciseEntity(by id: UUID, context: NSManagedObjectContext) -> ExerciseEntity? {
        let fetchRequest: NSFetchRequest<ExerciseEntity> = ExerciseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            print("Failed to fetch ExerciseEntity with id \(id): \(error)")
            return nil
        }
    }

    // Fetch all selected exercises from Core Data
    private func fetchSelectedExercises(context: NSManagedObjectContext) -> [ExerciseEntity] {
        let fetchRequest: NSFetchRequest<ExerciseEntity> = ExerciseEntity.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch exercises: \(error)")
            return []
        }
    }
}
