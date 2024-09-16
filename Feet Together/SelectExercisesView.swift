//
//  SelectExercisesView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/14/24.
//

import SwiftUI
import CoreData

struct SelectExercisesView: View {
    @Binding var session: TrainingSession
    var allExercises: [Exercise]

    @Environment(\.managedObjectContext) private var context
    @State var selectedExercises: [String: Bool] = [:]  // Holds UUIDs as strings for the exercise selection

    var body: some View {
        List {
            ForEach(allExercises) { exercise in
                HStack {
                    Text(exercise.name)
                    Spacer()
                    Toggle(isOn: Binding<Bool>(
                        get: {
                            let idString = exercise.id.uuidString
                            return selectedExercises[idString] ?? false
                        },
                        set: { newValue in
                            let idString = exercise.id.uuidString
                            print("Toggling exercise \(exercise.name) to \(newValue)")
                            selectedExercises[idString] = newValue
                            // Save the toggle state immediately
                            saveExerciseSelection(id: idString, isSelected: newValue, context: context)
                        }
                    )) {
                        Text("")
                    }
                    .labelsHidden()
                }
            }
        }
        .navigationTitle("Select Exercises")
        .onAppear {
            loadSelectedExercises(context: context)
        }
    }

    // Load selected exercises from Core Data and merge with session
    private func loadSelectedExercises(context: NSManagedObjectContext) {
        // Fetch selected exercises from Core Data
        let fetchedSelectedExercises = CoreDataHelper.shared.fetchSelectedExercises(context: context)

        // Convert fetched exercises to a dictionary
        var exercisesDictionary: [String: Bool] = [:]
        for exercise in fetchedSelectedExercises {
            if let id = exercise.id?.uuidString {
                exercisesDictionary[id] = exercise.isSelected
            }
        }

        // Merge with session's selected exercises
        let sessionExercises = session.selectedExercises
        for (uuid, selected) in sessionExercises {
            exercisesDictionary[uuid.uuidString] = selected
        }

        // Assign the merged result to selectedExercises
        selectedExercises = exercisesDictionary
    }

    // Save selected exercises immediately when toggled
    private func saveExerciseSelection(id: String, isSelected: Bool, context: NSManagedObjectContext) {
        if let exerciseUUID = UUID(uuidString: id), let existingExercise = fetchExerciseEntity(by: exerciseUUID, context: context) {
            existingExercise.isSelected = isSelected
        } else if let exerciseUUID = UUID(uuidString: id) {
            let newExerciseEntity = ExerciseEntity(context: context)
            newExerciseEntity.id = exerciseUUID
            newExerciseEntity.isSelected = isSelected
        }

        // Save Core Data
        do {
            try context.save()
            print("Saved \(id) selection: \(isSelected) to Core Data")
        } catch {
            print("Error saving exercise \(id) selection: \(error)")
        }
    }

    // Fetch ExerciseEntity by id
    func fetchExerciseEntity(by id: UUID, context: NSManagedObjectContext) -> ExerciseEntity? {
        let fetchRequest: NSFetchRequest<ExerciseEntity> = ExerciseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching ExerciseEntity by id: \(error)")
            return nil
        }
    }
}
