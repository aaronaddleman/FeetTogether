//
//  EditTechniquesView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI

struct EditTechniquesView: View {
    @Binding var session: TrainingSession

    var body: some View {
        List {
            if let techniquesSection = session.sections.first(where: { $0.type == .technique }) {
                ForEach(techniquesSection.items, id: \.id) { technique in
                    HStack {
                        Text(technique.name)
                        Spacer()
                        Toggle("", isOn: toggleBinding(for: technique, in: techniquesSection))
                            .labelsHidden()
                    }
                }
            } else {
                Text("No techniques found.")
            }
        }
        .toolbar {
            EditButton() // Enables drag-and-drop if necessary
        }
        .navigationTitle("Edit Techniques")
    }

    // Toggle Binding for Item Activation
    private func toggleBinding(for item: AnyTrainingItem, in section: TrainingSection) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                session.sections.first(where: { $0.type == .technique })?.items.contains(where: { $0.id == item.id }) ?? false
            },
            set: { newValue in
                toggleItem(item, in: section, isActive: newValue)
            }
        )
    }

    // Toggle Item Activation
    private func toggleItem(_ item: AnyTrainingItem, in section: TrainingSection, isActive: Bool) {
        if let sectionIndex = session.sections.firstIndex(where: { $0.id == section.id }) {
            if isActive {
                if !session.sections[sectionIndex].items.contains(where: { $0.id == item.id }) {
                    session.sections[sectionIndex].items.append(item)
                }
            } else {
                if let itemIndex = session.sections[sectionIndex].items.firstIndex(where: { $0.id == item.id }) {
                    session.sections[sectionIndex].items.remove(at: itemIndex)
                }
            }
        }
    }
}
