//
//  EditExerciseView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI

struct EditExercisesView: View {
    @Binding var session: TrainingSession
    @Binding var allExercises: [Exercise]
    @State private var toggleStates: [UUID: Bool] = [:]

    var body: some View {
        List {
            // Drag-and-drop and toggling of exercises
            ForEach(allExercises, id: \.id) { exercise in
                HStack {
                    Text(exercise.name)
                    Spacer()
                    Toggle("", isOn: toggleBinding(for: AnyTrainingItem(exercise), sectionType: .exercise))
                        .labelsHidden()
                }
            }
            .onMove(perform: moveExercises)
        }
        .toolbar {
            EditButton() // Enables drag-and-drop
        }
        .navigationTitle("Edit Exercises")
        .onAppear {
            initializeToggleStates()
        }
    }

    // Initialize the toggle states from the session
    private func initializeToggleStates() {
        for exercise in allExercises {
            toggleStates[exercise.id] = session.sections.first { $0.type == .exercise }?.items.contains(where: { $0.id == exercise.id }) ?? false
        }
    }

    // Toggle Binding for Item Activation
    private func toggleBinding(for item: AnyTrainingItem, sectionType: SectionType) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                toggleStates[item.id] ?? false
            },
            set: { newValue in
                toggleStates[item.id] = newValue
                toggleItem(item, in: sectionType, isActive: newValue)
            }
        )
    }

    // Move exercises during drag-and-drop
    private func moveExercises(from source: IndexSet, to destination: Int) {
        allExercises.move(fromOffsets: source, toOffset: destination)
    }

    // Toggle Item Activation
    private func toggleItem(_ item: AnyTrainingItem, in sectionType: SectionType, isActive: Bool) {
        if let sectionIndex = session.sections.firstIndex(where: { $0.type == sectionType }) {
            if isActive {
                if !session.sections[sectionIndex].items.contains(where: { $0.id == item.id }) {
                    session.sections[sectionIndex].items.append(item)
                }
            } else {
                if let itemIndex = session.sections[sectionIndex].items.firstIndex(where: { $0.id == item.id }) {
                    session.sections[sectionIndex].items.remove(at: itemIndex)
                }
            }
        } else if isActive {
            session.sections.append(TrainingSection(type: sectionType, items: [item]))
        }
    }
}
