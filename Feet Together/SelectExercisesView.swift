//
//  SelectExercisesView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI

struct SelectExercisesView: View {
    @Binding var session: TrainingSession
    @Binding var allExercises: [Exercise]
    @State private var localSections: [TrainingSection]

    init(session: Binding<TrainingSession>, allExercises: Binding<[Exercise]>) {
        self._session = session
        self._allExercises = allExercises
        self._localSections = State(initialValue: session.wrappedValue.sections)
    }

    var body: some View {
        List {
            ForEach(allExercises) { exercise in
                HStack {
                    Text(exercise.name)
                    Spacer()
                    Toggle(isOn: isExerciseSelectedBinding(for: exercise)) {
                        Text("")
                    }
                    .labelsHidden()
                }
            }
        }
        .navigationTitle("Select Exercises")
        .onDisappear {
            // Save selected exercises while preserving other sections (techniques, katas)
            saveSelectedExercises()
        }
    }

    private func isExerciseSelectedBinding(for exercise: Exercise) -> Binding<Bool> {
        return Binding<Bool>(
            get: {
                isSelected(exercise: exercise)
            },
            set: { newValue in
                withAnimation {
                    toggleExercise(exercise, isSelected: newValue)
                }
            }
        )
    }

    private func isSelected(exercise: Exercise) -> Bool {
        if let exercisesSection = localSections.first(where: { $0.type == .exercise }) {
            return exercisesSection.items.contains { $0.id == exercise.id }
        }
        return false
    }

    private func toggleExercise(_ exercise: Exercise, isSelected: Bool) {
        if let sectionIndex = localSections.firstIndex(where: { $0.type == .exercise }) {
            if isSelected {
                if !localSections[sectionIndex].items.contains(where: { $0.id == exercise.id }) {
                    let newItem = AnyTrainingItem(exercise)
                    localSections[sectionIndex].items.append(newItem)
                }
            } else {
                if let itemIndex = localSections[sectionIndex].items.firstIndex(where: { $0.id == exercise.id }) {
                    localSections[sectionIndex].items.remove(at: itemIndex)
                }
            }
        } else if isSelected {
            let newSection = TrainingSection(type: .exercise, items: [AnyTrainingItem(exercise)])
            localSections.append(newSection)
        }
    }

    private func saveSelectedExercises() {
        // Preserve other sections (e.g., techniques, katas) while updating the exercises section
        if let sectionIndex = localSections.firstIndex(where: { $0.type == .exercise }) {
            if let sessionSectionIndex = session.sections.firstIndex(where: { $0.type == .exercise }) {
                session.sections[sessionSectionIndex] = localSections[sectionIndex]
            } else {
                session.sections.append(localSections[sectionIndex])
            }
        }
    }
}
