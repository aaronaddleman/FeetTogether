//
//  SelectKatasView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI

struct SelectKatasView: View {
    @Binding var session: TrainingSession
    var allKatas: [Kata]

    // Local state for tracking selected katas
    @State private var selectedKatas: [UUID: Bool] = [:]

    init(session: Binding<TrainingSession>, allKatas: [Kata]) {
        self._session = session
        self.allKatas = allKatas
        
        // Initialize local selectedKatas from the session's state
        let initialSelectedKatas = session.wrappedValue.selectedKatas
        print("Initializing selected katas from session: \(initialSelectedKatas)")
        _selectedKatas = State(initialValue: initialSelectedKatas)
    }

    var body: some View {
        List {
            ForEach(allKatas) { kata in
                HStack {
                    Text(kata.name)
                    Spacer()
                    Toggle(isOn: Binding<Bool>(
                        get: {
                            let isSelected = selectedKatas[kata.id] ?? false
                            print("Kata \(kata.name) is selected: \(isSelected)")
                            return isSelected
                        },
                        set: { newValue in
                            print("Toggling \(kata.name) to \(newValue)")
                            selectedKatas[kata.id] = newValue
                        }
                    )) {
                        Text("")
                    }
                    .labelsHidden()
                }
            }
        }
        .navigationTitle("Select Katas")
        .onDisappear {
            saveSelectedKatas()
        }
    }

    private func saveSelectedKatas() {
        // Log the current selected katas for debugging
        let selectedKatasList = selectedKatas.filter { $0.value == true }
        print("Selected Katas to save: \(selectedKatasList.map { $0.key })")

        // Remove old katas section from session
        print("Removing old katas section from session")
        session.sections.removeAll { $0.type == .kata }

        // Create a new section with the selected katas
        let selectedItems = allKatas.filter { selectedKatas[$0.id] == true }.map { AnyTrainingItem($0) }
        if !selectedItems.isEmpty {
            let newSection = TrainingSection(type: .kata, items: selectedItems)
            print("Adding new katas section: \(newSection.items.map { $0.name })")
            session.sections.append(newSection)
        } else {
            print("No katas selected, no section added")
        }

        // Update the session's selectedKatas with the local state
        session.selectedKatas = selectedKatas
        print("Session's selectedKatas updated: \(session.selectedKatas)")
    }
}
