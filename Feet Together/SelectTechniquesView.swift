//
//  SelectTechniquesView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI
import CoreData

struct SelectTechniquesView: View {
    @Binding var session: TrainingSession
    var allTechniques: [Technique]

    @Environment(\.managedObjectContext) private var context
    @State var selectedTechniques: [UUID: Bool] = [:]  // Holds UUIDs for the technique selection
    @State private var isSaving = false  // Flag to control saving
    @State private var isViewActive = true  // Ensure view stays active

    var body: some View {
        List {
            // Display all techniques, whether selected or not
            ForEach(allTechniques) { technique in
                HStack {
                    Text(technique.name.isEmpty ? "Unknown Technique" : technique.name)
                    Spacer()
                    Toggle(isOn: Binding<Bool>(
                        get: {
                            // Default to false if the technique isn't already in selectedTechniques
                            selectedTechniques[technique.id] ?? session.selectedTechniques[technique.id] ?? false
                        },
                        set: { newValue in
                            selectedTechniques[technique.id] = newValue
                            session.selectedTechniques[technique.id] = newValue  // Update the session's selected techniques
                            saveTechniqueSelection(technique: technique, isSelected: newValue)
                            print("Toggled technique: \(technique.name), New Value: \(newValue)")
                        }
                    )) {
                        Text("")
                    }
                    .labelsHidden()
                }
            }
        }
        .navigationTitle("Select Techniques")
        .onAppear {
            print("SelectTechniquesView appeared")
            loadSelectedTechniques()
            logTechniqueCounts()
        }
        .onDisappear {
            print("SelectTechniquesView disappeared")
            saveSelectedTechniques()
            print("Saving all selected techniques...")
        }
    }

    // Load selected techniques for the current session
    private func loadSelectedTechniques() {
        print("Loaded \(session.selectedTechniques.count) selected techniques.")
        selectedTechniques = session.selectedTechniques
    }

    // Save individual technique selection
    private func saveTechniqueSelection(technique: Technique, isSelected: Bool) {
        session.selectedTechniques[technique.id] = isSelected
        print("Saved technique selection for \(technique.name): \(isSelected)")

        isSaving = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let existingTechnique = fetchTechniqueEntity(by: technique.id, context: context) {
                existingTechnique.isSelected = isSelected
            } else {
                let newTechniqueEntity = TechniqueEntity(context: context)
                newTechniqueEntity.id = technique.id
                newTechniqueEntity.isSelected = isSelected
            }

            do {
                try context.save()
                print("Saved \(technique.name) to Core Data.")
            } catch {
                print("Failed to save technique to Core Data: \(error)")
            }

            isSaving = false
        }
    }

    // Save all selected techniques onDisappear
    private func saveSelectedTechniques() {
        for (id, isSelected) in selectedTechniques {
            if let techniqueEntity = fetchTechniqueEntity(by: id, context: context) {
                techniqueEntity.isSelected = isSelected
            } else {
                let newTechniqueEntity = TechniqueEntity(context: context)
                newTechniqueEntity.id = id
                newTechniqueEntity.isSelected = isSelected
            }
        }

        do {
            try context.save()
            print("Successfully saved all selected techniques to Core Data.")
        } catch {
            print("Failed to save selected techniques: \(error)")
        }
    }

    // Fetch TechniqueEntity by id
    private func fetchTechniqueEntity(by id: UUID, context: NSManagedObjectContext) -> TechniqueEntity? {
        let request: NSFetchRequest<TechniqueEntity> = TechniqueEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        return try? context.fetch(request).first
    }

    // Log counts of techniques
    private func logTechniqueCounts() {
        let availableTechniquesCount = allTechniques.count
        let selectedTechniquesCount = session.selectedTechniques.filter { $0.value == true }.count

        print("Total available techniques: \(availableTechniquesCount)")
        print("Total selected techniques: \(selectedTechniquesCount)")
    }
}
