//
//  EditTechniquesView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI
import CoreData

struct EditTechniquesView: View {
    @Binding var session: TrainingSession
    @Binding var allTechniques: [Technique]
    @State private var selectedTechniques: [UUID: Bool] = [:]  // Track selected techniques by UUID
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        List {
            ForEach(allTechniques) { technique in
                HStack {
                    Text(technique.name)
                    Spacer()
                    Toggle("", isOn: toggleBinding(for: technique))
                        .labelsHidden()
                }
            }
        }
        .toolbar {
            EditButton() // Enables drag-and-drop if necessary
        }
        .navigationTitle("Edit Techniques")
        .onAppear {
            print("onAppear: Loading selected techniques...")
            loadSelectedTechniques()  // Load techniques on appear
        }
        .onDisappear {
            print("onDisappear: Saving selected techniques...")
            saveSelectedTechniques()  // Save techniques on disappear
        }
    }

    // Toggle Binding for Technique Activation
    private func toggleBinding(for technique: Technique) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                let isSelected = selectedTechniques[technique.id] ?? false
                print("EditTechniqueView: Technique \(technique.name) is selected: \(isSelected)")
                return isSelected
            },
            set: { newValue in
                print("Toggling technique \(technique.name) (\(technique.id)) to \(newValue)")
                selectedTechniques[technique.id] = newValue  // Update selection by UUID
            }
        )
    }

    // Save selected techniques to Core Data and session
    private func saveSelectedTechniques() {
        print("Saving selected techniques...")
        print("Selected techniques before save: \(selectedTechniques)")

        for technique in allTechniques {
            let isSelected = selectedTechniques[technique.id] ?? false
            print("Technique \(technique.name) isSelected: \(isSelected)")
            
            // Fetch or create a corresponding TechniqueEntity in Core Data
            var techniqueEntity = fetchTechniqueEntity(by: technique.id)
            
            if techniqueEntity == nil {
                print("Creating new TechniqueEntity for id: \(technique.id)")
                techniqueEntity = TechniqueEntity(context: context)
                techniqueEntity?.id = technique.id
                techniqueEntity?.name = technique.name
            }
            
            // Update the `isSelected` property in Core Data
            techniqueEntity?.isSelected = isSelected
        }

        // Save the Core Data context and handle errors
        do {
            try context.save()  // Ensure the context is saved with updated selections
            print("Core Data context for techniques saved successfully.")
        } catch {
            print("Failed to save techniques in Core Data: \(error)")
        }

        // Update the session's selectedTechniques with UUIDs
        session.selectedTechniques = selectedTechniques
        print("Session's selectedTechniques updated: \(session.selectedTechniques)")
        print("Selected techniques after save: \(selectedTechniques)")
        
        // Double check if the session retains these values after the view disappears
        if session.selectedTechniques.isEmpty {
            print("Warning: session.selectedTechniques is empty after save!")
        }
    }

    // Load selected techniques from Core Data and merge with session
    private func loadSelectedTechniques() {
        print("Loading selected techniques from Core Data...")
        
        // Fetch from Core Data
        let fetchedSelectedTechniques = fetchSelectedTechniques()
        
        var techniquesDictionary: [UUID: Bool] = [:]
        for technique in fetchedSelectedTechniques {
            if let id = technique.id {
                techniquesDictionary[id] = technique.isSelected
                print("Loaded technique from Core Data: \(technique.name ?? "Unknown Name") isSelected: \(technique.isSelected)")
            }
        }

        // Merge session's selected techniques with Core Data values
        let sessionSelectedTechniques = session.selectedTechniques
        if sessionSelectedTechniques.isEmpty {
            print("Warning: session.selectedTechniques is empty when loading!")
        }
        
        for (uuid, selected) in sessionSelectedTechniques {
            techniquesDictionary[uuid] = selected
            print("Merging technique from session: \(uuid) isSelected: \(selected)")
        }

        // Log the final merged state
        print("Final merged state of selected techniques: \(techniquesDictionary)")
        
        // Update the in-memory `selectedTechniques`
        selectedTechniques = techniquesDictionary
    }


    // Fetch TechniqueEntity from Core Data by UUID
    private func fetchTechniqueEntity(by id: UUID) -> TechniqueEntity? {
        let fetchRequest: NSFetchRequest<TechniqueEntity> = TechniqueEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            print("Failed to fetch TechniqueEntity with id \(id): \(error)")
            return nil
        }
    }

    // Fetch all selected techniques from Core Data
    private func fetchSelectedTechniques() -> [TechniqueEntity] {
        let fetchRequest: NSFetchRequest<TechniqueEntity> = TechniqueEntity.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch techniques: \(error)")
            return []
        }
    }
}
