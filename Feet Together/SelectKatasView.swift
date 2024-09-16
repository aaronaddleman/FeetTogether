//
//  SelectKatasView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI
import CoreData

struct SelectKatasView: View {
    @Binding var session: TrainingSession
    var allKatas: [Kata]

    @Environment(\.managedObjectContext) private var context
    @State private var selectedKatas: [String: Bool] = [:]  // Updated to use String for UUIDs

    var body: some View {
        List {
            ForEach(allKatas) { kata in
                HStack {
                    Text(kata.name)
                    Spacer()
                    Toggle(isOn: Binding<Bool>(
                        get: {
                            let idString = kata.id.uuidString  // Convert UUID to String
                            return selectedKatas[idString] ?? false
                        },
                        set: { newValue in
                            let idString = kata.id.uuidString  // Convert UUID to String
                            print("Toggling Kata \(kata.name) to \(newValue)")
                            selectedKatas[idString] = newValue
                            saveKataSelection(id: idString, isSelected: newValue, context: context)  // Save immediately
                        }
                    )) {
                        Text("")
                    }
                    .labelsHidden()
                }
            }
        }
        .navigationTitle("Select Katas")
        .onAppear {
            loadSelectedKatas(context: context)
        }
        .onDisappear {
            print("onDisappear called: Saving selected katas...")
            print("Selected katas before save: \(selectedKatas)")
            saveSelectedKatas(context: context)
            print("Selected katas after save: \(selectedKatas)")
        }
    }

    // Load selected Katas from Core Data and merge with session
    private func loadSelectedKatas(context: NSManagedObjectContext) {
        let fetchedSelectedKatas = CoreDataHelper.shared.fetchSelectedKatas(context: context)

        // Convert fetched katas to a dictionary
        var katasDictionary: [String: Bool] = [:]
        for kata in fetchedSelectedKatas {
            if let id = kata.id?.uuidString {
                katasDictionary[id] = kata.isSelected
            }
        }

        // Merge with session's selected Katas
        let sessionKatas = session.selectedKatas
        for (uuid, selected) in sessionKatas {
            katasDictionary[uuid.uuidString] = selected
        }

        // Now assign the merged result to selectedKatas
        selectedKatas = katasDictionary
    }

    // Save selected Katas immediately when toggled
    private func saveKataSelection(id: String, isSelected: Bool, context: NSManagedObjectContext) {
        if let kataUUID = UUID(uuidString: id), let existingKata = fetchKataEntity(by: kataUUID, context: context) {
            existingKata.isSelected = isSelected
        } else if let kataUUID = UUID(uuidString: id) {
            let newKataEntity = KataEntity(context: context)
            newKataEntity.id = kataUUID
            newKataEntity.isSelected = isSelected
        }

        // Save Core Data
        do {
            try context.save()
            print("Saved \(id) selection: \(isSelected) to Core Data")
        } catch {
            print("Error saving kata \(id) selection: \(error)")
        }
    }

    // Save all selected Katas onDisappear (backup)
    private func saveSelectedKatas(context: NSManagedObjectContext) {
        var selectedKatasUUID: [UUID: Bool] = [:]

        for (idString, isSelected) in selectedKatas {
            if let kataUUID = UUID(uuidString: idString) {
                selectedKatasUUID[kataUUID] = isSelected
            }
        }

        for (kataUUID, isSelected) in selectedKatasUUID {
            if let existingKata = fetchKataEntity(by: kataUUID, context: context) {
                existingKata.isSelected = isSelected
            } else {
                let newKataEntity = KataEntity(context: context)
                newKataEntity.id = kataUUID
                newKataEntity.isSelected = isSelected
            }
        }

        // Save Core Data
        do {
            try context.save()
        } catch {
            print("Error saving selected Katas: \(error)")
        }

        // Update the session object
        session.selectedKatas = selectedKatasUUID
    }

    // Fetch KataEntity by id
    func fetchKataEntity(by id: UUID, context: NSManagedObjectContext) -> KataEntity? {
        let fetchRequest: NSFetchRequest<KataEntity> = KataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching KataEntity by id: \(error)")
            return nil
        }
    }
}
