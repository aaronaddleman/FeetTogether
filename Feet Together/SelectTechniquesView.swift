//
//  SelectTechniquesView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI

struct SelectTechniquesView: View {
    @Binding var session: TrainingSession
    @Binding var allTechniques: [Technique]
    @State private var localSections: [TrainingSection]

    init(session: Binding<TrainingSession>, allTechniques: Binding<[Technique]>) {
        self._session = session
        self._allTechniques = allTechniques
        self._localSections = State(initialValue: session.wrappedValue.sections)
    }

    var body: some View {
        List {
            ForEach(allTechniques) { technique in
                HStack {
                    Text(technique.name)
                    Spacer()
                    Toggle(isOn: isTechniqueSelectedBinding(for: technique)) {
                        Text("")
                    }
                    .labelsHidden()
                }
            }
        }
        .navigationTitle("Select Techniques")
        .onDisappear {
            // Save selected techniques and keep other sections intact
            saveSelectedTechniques()
        }
    }

    private func isTechniqueSelectedBinding(for technique: Technique) -> Binding<Bool> {
        return Binding<Bool>(
            get: {
                isSelected(technique: technique)
            },
            set: { newValue in
                withAnimation {
                    toggleTechnique(technique, isSelected: newValue)
                }
            }
        )
    }

    private func isSelected(technique: Technique) -> Bool {
        if let techniquesSection = localSections.first(where: { $0.type == .technique }) {
            return techniquesSection.items.contains { $0.id == technique.id }
        }
        return false
    }

    private func toggleTechnique(_ technique: Technique, isSelected: Bool) {
        if let sectionIndex = localSections.firstIndex(where: { $0.type == .technique }) {
            if isSelected {
                if !localSections[sectionIndex].items.contains(where: { $0.id == technique.id }) {
                    let newItem = AnyTrainingItem(technique)
                    localSections[sectionIndex].items.append(newItem)
                }
            } else {
                if let itemIndex = localSections[sectionIndex].items.firstIndex(where: { $0.id == technique.id }) {
                    localSections[sectionIndex].items.remove(at: itemIndex)
                }
            }
        } else if isSelected {
            let newSection = TrainingSection(type: .technique, items: [AnyTrainingItem(technique)])
            localSections.append(newSection)
        }
    }

    private func saveSelectedTechniques() {
        // Preserve other sections (e.g., exercises, katas) while updating the techniques section
        if let sectionIndex = localSections.firstIndex(where: { $0.type == .technique }) {
            if let sessionSectionIndex = session.sections.firstIndex(where: { $0.type == .technique }) {
                session.sections[sessionSectionIndex] = localSections[sectionIndex]
            } else {
                session.sections.append(localSections[sectionIndex])
            }
        }
    }
}
