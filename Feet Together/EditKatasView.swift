//
//  EditKatasView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

//
//  EditKatasView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI
import CoreData

struct EditKatasView: View {
    @Binding var session: TrainingSession
    @Binding var allKatas: [Kata]  // Bind all katas from the main list
    @State private var selectedKatas: [UUID: Bool] = [:]  // Local state to track selected katas
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        List {
            // Use allKatas to display available katas
            ForEach(allKatas) { kata in
                HStack {
                    Text(kata.name)
                    Spacer()
                    Toggle("", isOn: toggleBinding(for: kata))
                        .labelsHidden()
                }
            }
        }
        .toolbar {
            EditButton() // Enables drag-and-drop if necessary
        }
        .navigationTitle("Edit Katas")
        .onAppear {
            loadSelectedKatas()  // Load katas on appear
        }
        .onDisappear {
            saveSelectedKatas()  // Save katas on disappear
        }
    }

    // Toggle Binding for Kata Activation
    private func toggleBinding(for kata: Kata) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                selectedKatas[kata.id] ?? false  // Use kata.id as UUID
            },
            set: { newValue in
                selectedKatas[kata.id] = newValue  // Update selection by UUID
            }
        )
    }

    // Save selected katas to Core Data and session
    private func saveSelectedKatas() {
        print("Saving selected katas...")

        for kata in allKatas {
            let isSelected = selectedKatas[kata.id] ?? false
            print("Kata \(kata.name) isSelected: \(isSelected)")

            // Fetch or create a corresponding KataEntity in Core Data
            var kataEntity = fetchKataEntity(by: kata.id, context: context)

            if kataEntity == nil {
                // Create a new KataEntity if not found
                print("Creating new KataEntity for id: \(kata.id)")
                kataEntity = KataEntity(context: context)
                kataEntity?.id = kata.id
                kataEntity?.name = kata.name
            }

            // Update the `isSelected` property
            kataEntity?.isSelected = isSelected
        }

        do {
            try context.save()  // Ensure the context is saved with updated selections
            print("Core Data context for katas saved successfully.")
        } catch {
            print("Failed to save katas in Core Data: \(error)")
        }

        // Update session's selectedKatas with UUIDs
        session.selectedKatas = selectedKatas
        print("Session's selectedKatas updated: \(session.selectedKatas)")
    }

    // Load selected katas from Core Data and merge with session
    private func loadSelectedKatas() {
        print("Loading selected katas from Core Data and session...")
        let fetchedSelectedKatas = fetchSelectedKatas(context: context)

        var katasDictionary: [UUID: Bool] = [:]
        for kataEntity in fetchedSelectedKatas {
            if let id = kataEntity.id {
                katasDictionary[id] = kataEntity.isSelected
                print("Loaded kata from Core Data: \(kataEntity.name ?? "Unknown Name") isSelected: \(kataEntity.isSelected)")
            }
        }

        let initialSelectedKatas = session.selectedKatas
        for (uuid, selected) in initialSelectedKatas {
            katasDictionary[uuid] = selected
            print("Merging kata from session: \(uuid) isSelected: \(selected)")
        }

        print("Final merged state of selected katas: \(katasDictionary)")
        selectedKatas = katasDictionary
    }

    // Fetch KataEntity from Core Data by UUID
    private func fetchKataEntity(by id: UUID, context: NSManagedObjectContext) -> KataEntity? {
        let fetchRequest: NSFetchRequest<KataEntity> = KataEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            print("Failed to fetch KataEntity with id \(id): \(error)")
            return nil
        }
    }

    // Fetch all selected katas from Core Data
    private func fetchSelectedKatas(context: NSManagedObjectContext) -> [KataEntity] {
        let fetchRequest: NSFetchRequest<KataEntity> = KataEntity.fetchRequest()

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch katas: \(error)")
            return []
        }
    }
}
