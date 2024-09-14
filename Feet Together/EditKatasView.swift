//
//  EditKatasView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI

struct EditKatasView: View {
    @Binding var session: TrainingSession
    @Binding var allKatas: [Kata]
    @State private var toggleStates: [UUID: Bool] = [:]

    var body: some View {
        List {
            // Drag-and-drop and toggling of katas
            ForEach(allKatas, id: \.id) { kata in
                HStack {
                    Text(kata.name)
                    Spacer()
                    Toggle("", isOn: toggleBinding(for: AnyTrainingItem(kata), sectionType: .kata))
                        .labelsHidden()
                }
            }
            .onMove(perform: moveKatas)
        }
        .toolbar {
            EditButton() // Enables drag-and-drop
        }
        .navigationTitle("Edit Katas")
        .onAppear {
            initializeToggleStates()
        }
    }

    // Initialize the toggle states from the session
    private func initializeToggleStates() {
        for kata in allKatas {
            toggleStates[kata.id] = session.sections.first { $0.type == .kata }?.items.contains(where: { $0.id == kata.id }) ?? false
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

    // Move katas during drag-and-drop
    private func moveKatas(from source: IndexSet, to destination: Int) {
        allKatas.move(fromOffsets: source, toOffset: destination)
    }

    // Toggle Item Activation
    private func toggleItem(_ item: AnyTrainingItem, in sectionType: SectionType, isActive: Bool) {
        if let sectionIndex = session.sections.firstIndex(where: { $0.type == sectionType }) {
            if isActive {
                // Add the item to the session if not already active
                if !session.sections[sectionIndex].items.contains(where: { $0.id == item.id }) {
                    session.sections[sectionIndex].items.append(item)
                    print("Item added: \(item.name)")
                }
            } else {
                // Remove the item from the session if it's currently active
                if let itemIndex = session.sections[sectionIndex].items.firstIndex(where: { $0.id == item.id }) {
                    session.sections[sectionIndex].items.remove(at: itemIndex)
                    print("Item removed: \(item.name)")
                }
                // Remove the section if empty
                if session.sections[sectionIndex].items.isEmpty {
                    session.sections.remove(at: sectionIndex)
                    print("Section removed as it is now empty")
                }
            }
        } else if isActive {
            // If section doesn't exist, create it and add the item
            let newSection = TrainingSection(type: sectionType, items: [item])
            session.sections.append(newSection)
            print("Created new section for: \(item.name)")
        }
    }
}
