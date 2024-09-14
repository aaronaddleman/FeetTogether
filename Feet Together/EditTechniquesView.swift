//
//  EditTechniquesView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI

// Updated ForEach with unique IDs and optimized state management
import SwiftUI

struct EditTechniquesView: View {
    @Binding var session: TrainingSession
    @Binding var allTechniques: [Technique]
    @State private var toggleStates: [UUID: Bool] = [:]

    var body: some View {
        List {
            // Drag-and-drop and toggling of techniques
            ForEach(allTechniques, id: \.id) { technique in
                HStack {
                    Text(technique.name)
                    Spacer()
                    Toggle("", isOn: toggleBinding(for: AnyTrainingItem(technique), sectionType: .technique))
                        .labelsHidden()
                }
            }
            .onMove(perform: moveTechniques)
        }
        .toolbar {
            EditButton() // Enables drag-and-drop
        }
        .navigationTitle("Edit Techniques")
        .onAppear {
            initializeToggleStates()
        }
    }

    // Initialize the toggle states from the session
    private func initializeToggleStates() {
        for technique in allTechniques {
            toggleStates[technique.id] = session.sections.first { $0.type == .technique }?.items.contains(where: { $0.id == technique.id }) ?? false
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

    // Move techniques during drag-and-drop
    private func moveTechniques(from source: IndexSet, to destination: Int) {
        allTechniques.move(fromOffsets: source, toOffset: destination)
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
