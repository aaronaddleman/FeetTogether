//
//  SelectExercisesView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI

struct SelectExercisesView: View {
    @Binding var session: TrainingSession
    var allExercises: [Exercise]

    // Local state for tracking selected exercises
    @State private var selectedExercises: [UUID: Bool] = [:]

    init(session: Binding<TrainingSession>, allExercises: [Exercise]) {
        self._session = session
        self.allExercises = allExercises
        
        // Initialize local selectedExercises from the session's state
        let initialSelectedExercises = session.wrappedValue.selectedExercises
        print("Initializing selected exercises from session: \(initialSelectedExercises)")
        _selectedExercises = State(initialValue: initialSelectedExercises)
    }

    var body: some View {
        List {
            ForEach(allExercises) { exercise in
                HStack {
                    Text(exercise.name)
                    Spacer()
                    Toggle(isOn: Binding<Bool>(
                        get: {
                            let isSelected = selectedExercises[exercise.id] ?? false
                            print("Exercise \(exercise.name) is selected: \(isSelected)")
                            return isSelected
                        },
                        set: { newValue in
                            print("Toggling \(exercise.name) to \(newValue)")
                            selectedExercises[exercise.id] = newValue
                        }
                    )) {
                        Text("")
                    }
                    .labelsHidden()
                }
            }
        }
        .navigationTitle("Select Exercises")
        .onDisappear {
            saveSelectedExercises()
        }
    }

    private func saveSelectedExercises() {
        // Log the current selected exercises for debugging
        let selectedExercisesList = selectedExercises.filter { $0.value == true }
        print("Selected Exercises to save: \(selectedExercisesList.map { $0.key })")

        // Remove old exercises section from session
        print("Removing old exercises section from session")
        session.sections.removeAll { $0.type == .exercise }

        // Create a new section with the selected exercises
        let selectedItems = allExercises.filter { selectedExercises[$0.id] == true }.map { AnyTrainingItem($0) }
        if !selectedItems.isEmpty {
            let newSection = TrainingSection(type: .exercise, items: selectedItems)
            print("Adding new exercises section: \(newSection.items.map { $0.name })")
            session.sections.append(newSection)
        } else {
            print("No exercises selected, no section added")
        }

        // Update the session's selectedExercises with the local state
        session.selectedExercises = selectedExercises
        print("Session's selectedExercises updated: \(session.selectedExercises)")
    }
}
