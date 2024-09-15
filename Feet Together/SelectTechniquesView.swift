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
    @State var selectedTechniques: [String: Bool] = [:]  // Holds UUIDs as strings for the technique selection

    var body: some View {
        List {
            ForEach(allTechniques) { technique in
                HStack {
                    Text(technique.name)
                    Spacer()
                    Toggle(isOn: Binding<Bool>(
                        get: {
                            let idString = technique.id.uuidString  // Convert UUID to String
                            let isSelected = selectedTechniques[idString] ?? false
                            print("Technique \(technique.name) is selected: \(isSelected)")
                            return isSelected
                        },
                        set: { newValue in
                            let idString = technique.id.uuidString  // Convert UUID to String
                            print("Toggling \(technique.name) to \(newValue)")
                            selectedTechniques[idString] = newValue
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
            loadSelectedTechniques(context: context)
        }
        .onDisappear {
            print("onDisappear called: Saving selected techniques...")
            print("Selected techniques before save: \(selectedTechniques)")
            saveSelectedTechniques(context: context)
            print("Selected techniques after save: \(selectedTechniques)")
        }
    }

    // Load selected techniques from Core Data and merge with session
    private func loadSelectedTechniques(context: NSManagedObjectContext) {
        // Fetch selected techniques from Core Data
        let fetchedSelectedTechniques = fetchSelectedTechniques(context: context)
        
        // Convert fetched techniques to a dictionary
        var techniquesDictionary: [String: Bool] = [:]
        for technique in fetchedSelectedTechniques {
            if let id = technique.id?.uuidString {
                techniquesDictionary[id] = technique.isSelected
                print("Loaded technique from Core Data: \(technique.name ?? "Unknown Name") isSelected: \(technique.isSelected)")
            }
        }

        // Merge the Core Data fetched state with the session state
        let initialSelectedTechniques = session.selectedTechniques
        for (uuid, selected) in initialSelectedTechniques {
            let uuidString = uuid.uuidString
            techniquesDictionary[uuidString] = selected
            print("Merging technique from session: \(uuidString) isSelected: \(selected)")
        }

        print("Final merged state of selected techniques: \(techniquesDictionary)")
        
        // Initialize selected techniques with the merged state
        selectedTechniques = techniquesDictionary
    }

    // Save selected techniques
    private func saveSelectedTechniques(context: NSManagedObjectContext) {
        // First convert the selected techniques from [String: Bool] to [UUID: Bool]
        var selectedTechniquesUUID: [UUID: Bool] = [:]
        
        for (techniqueIDString, isSelected) in selectedTechniques {
            if let techniqueUUID = UUID(uuidString: techniqueIDString) {
                selectedTechniquesUUID[techniqueUUID] = isSelected
            } else {
                print("Invalid UUID for techniqueIDString: \(techniqueIDString)")
            }
        }

        // Save to Core Data after conversion
        for (techniqueUUID, isSelected) in selectedTechniquesUUID {
            if let existingTechnique = fetchTechniqueEntity(by: techniqueUUID, context: context) {
                existingTechnique.isSelected = isSelected
            } else {
                let newTechniqueEntity = TechniqueEntity(context: context)
                newTechniqueEntity.id = techniqueUUID
                newTechniqueEntity.isSelected = isSelected
            }
        }

        // Save the Core Data context to persist changes
        do {
            try context.save()
            print("Core Data context saved successfully.")
        } catch {
            print("Failed to save techniques in Core Data: \(error)")
        }

        // Update the session's selectedTechniques with the updated [UUID: Bool]
        session.selectedTechniques = selectedTechniquesUUID
        print("Session's selectedTechniques updated: \(session.selectedTechniques)")
    }

    // Fetch TechniqueEntity by id
    func fetchTechniqueEntity(by id: UUID, context: NSManagedObjectContext) -> TechniqueEntity? {
        let fetchRequest: NSFetchRequest<TechniqueEntity> = TechniqueEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching TechniqueEntity by id: \(error)")
            return nil
        }
    }
}
