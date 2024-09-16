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
                            let idString = technique.id.uuidString
                            return selectedTechniques[idString] ?? false
                        },
                        set: { newValue in
                            let idString = technique.id.uuidString
                            print("Toggling technique \(technique.name) to \(newValue)")
                            selectedTechniques[idString] = newValue
                            // Save the toggle state immediately
                            saveTechniqueSelection(id: idString, isSelected: newValue, context: context)
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
        let fetchedSelectedTechniques = CoreDataHelper.shared.fetchSelectedTechniques(context: context)

        // Convert fetched techniques to a dictionary
        var techniquesDictionary: [String: Bool] = [:]
        for technique in fetchedSelectedTechniques {
            if let id = technique.id?.uuidString {
                techniquesDictionary[id] = technique.isSelected
            }
        }

        // Merge with session's selected techniques
        let sessionTechniques = session.selectedTechniques
        for (uuid, selected) in sessionTechniques {
            techniquesDictionary[uuid.uuidString] = selected
        }
        
        // Assign the merged result to selectedTechniques
        selectedTechniques = techniquesDictionary
    }

    // Save selected techniques immediately when toggled
    private func saveTechniqueSelection(id: String, isSelected: Bool, context: NSManagedObjectContext) {
        if let techniqueUUID = UUID(uuidString: id), let existingTechnique = fetchTechniqueEntity(by: techniqueUUID, context: context) {
            existingTechnique.isSelected = isSelected
        } else if let techniqueUUID = UUID(uuidString: id) {
            let newTechniqueEntity = TechniqueEntity(context: context)
            newTechniqueEntity.id = techniqueUUID
            newTechniqueEntity.isSelected = isSelected
        }

        // Save Core Data
        do {
            try context.save()
            print("Saved \(id) selection: \(isSelected) to Core Data")
        } catch {
            print("Error saving technique \(id) selection: \(error)")
        }
    }

    // Save selected techniques for all toggled changes onDisappear (backup)
    private func saveSelectedTechniques(context: NSManagedObjectContext) {
        var selectedTechniquesUUID: [UUID: Bool] = [:]
        
        for (idString, isSelected) in selectedTechniques {
            if let techniqueUUID = UUID(uuidString: idString) {
                selectedTechniquesUUID[techniqueUUID] = isSelected
            }
        }

        for (techniqueUUID, isSelected) in selectedTechniquesUUID {
            if let existingTechnique = fetchTechniqueEntity(by: techniqueUUID, context: context) {
                existingTechnique.isSelected = isSelected
            } else {
                let newTechniqueEntity = TechniqueEntity(context: context)
                newTechniqueEntity.id = techniqueUUID
                newTechniqueEntity.isSelected = isSelected
            }
        }

        // Save Core Data
        do {
            try context.save()
        } catch {
            print("Error saving selected techniques: \(error)")
        }

        // Update the session object
        session.selectedTechniques = selectedTechniquesUUID
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
