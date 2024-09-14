//
//  EditKatasView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI

struct EditKatasView: View {
    @Binding var session: TrainingSession

    var body: some View {
        List {
            // Find the Katas section from the session
            if let katasSection = session.sections.first(where: { $0.type == .kata }) {
                ForEach(katasSection.items, id: \.id) { kata in
                    HStack {
                        Text(kata.name)
                        Spacer()
                        Toggle("", isOn: toggleBinding(for: kata, in: katasSection))
                            .labelsHidden()
                    }
                }
            } else {
                Text("No katas found.")
            }
        }
        .toolbar {
            EditButton() // Enables drag-and-drop if necessary
        }
        .navigationTitle("Edit Katas")
    }

    // Toggle Binding for Item Activation
    private func toggleBinding(for item: AnyTrainingItem, in section: TrainingSection) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                session.sections.first(where: { $0.type == .kata })?.items.contains(where: { $0.id == item.id }) ?? false
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
                // Add the item if it's not already active
                if !session.sections[sectionIndex].items.contains(where: { $0.id == item.id }) {
                    session.sections[sectionIndex].items.append(item)
                }
            } else {
                // Remove the item if it's currently active
                if let itemIndex = session.sections[sectionIndex].items.firstIndex(where: { $0.id == item.id }) {
                    session.sections[sectionIndex].items.remove(at: itemIndex)
                }
            }
        }
    }
}

