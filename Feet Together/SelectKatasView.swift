//
//  SelectKatasView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI

struct SelectKatasView: View {
    @Binding var session: TrainingSession
    @Binding var allKatas: [Kata]
    @State private var localSections: [TrainingSection]

    init(session: Binding<TrainingSession>, allKatas: Binding<[Kata]>) {
        self._session = session
        self._allKatas = allKatas
        self._localSections = State(initialValue: session.wrappedValue.sections)
    }

    var body: some View {
        List {
            ForEach(allKatas) { kata in
                HStack {
                    Text(kata.name)
                    Spacer()
                    Toggle(isOn: isKataSelectedBinding(for: kata)) {
                        Text("")
                    }
                    .labelsHidden()
                }
            }
        }
        .navigationTitle("Select Katas")
        .onDisappear {
            // Save selected katas while preserving other sections (techniques, exercises)
            saveSelectedKatas()
        }
    }

    private func isKataSelectedBinding(for kata: Kata) -> Binding<Bool> {
        return Binding<Bool>(
            get: {
                isSelected(kata: kata)
            },
            set: { newValue in
                withAnimation {
                    toggleKata(kata, isSelected: newValue)
                }
            }
        )
    }

    private func isSelected(kata: Kata) -> Bool {
        if let katasSection = localSections.first(where: { $0.type == .kata }) {
            return katasSection.items.contains { $0.id == kata.id }
        }
        return false
    }

    private func toggleKata(_ kata: Kata, isSelected: Bool) {
        if let sectionIndex = localSections.firstIndex(where: { $0.type == .kata }) {
            if isSelected {
                if !localSections[sectionIndex].items.contains(where: { $0.id == kata.id }) {
                    let newItem = AnyTrainingItem(kata)
                    localSections[sectionIndex].items.append(newItem)
                }
            } else {
                if let itemIndex = localSections[sectionIndex].items.firstIndex(where: { $0.id == kata.id }) {
                    localSections[sectionIndex].items.remove(at: itemIndex)
                }
            }
        } else if isSelected {
            let newSection = TrainingSection(type: .kata, items: [AnyTrainingItem(kata)])
            localSections.append(newSection)
        }
    }

    private func saveSelectedKatas() {
        // Preserve other sections (e.g., techniques, exercises) while updating the katas section
        if let sectionIndex = localSections.firstIndex(where: { $0.type == .kata }) {
            if let sessionSectionIndex = session.sections.firstIndex(where: { $0.type == .kata }) {
                session.sections[sessionSectionIndex] = localSections[sectionIndex]
            } else {
                session.sections.append(localSections[sectionIndex])
            }
        }
    }
}
