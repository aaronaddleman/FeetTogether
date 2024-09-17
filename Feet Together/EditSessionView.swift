//
//  EditSessionView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import SwiftUI
import CoreData

struct EditSessionView: View {
    @Binding var session: TrainingSession
    @Binding var allTechniques: [Technique]
    @Binding var allExercises: [Exercise]
    @Binding var allKatas: [Kata]

    @Environment(\.managedObjectContext) private var context
    
    @State private var isDataInitialized = false // Flag to ensure initialization happens once

    var body: some View {
        Form {
            Section(header: Text("Session Name")) {
                TextField("Session Name", text: $session.name)
            }

            Section(header: Text("Set Time Between Techniques")) {
                HStack {
                    Text("Time (seconds):")
                    Spacer()
                    TextField("Seconds", value: $session.timeBetweenTechniques, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                        .multilineTextAlignment(.trailing)
                }
            }

            // New section to list Sections: Techniques, Exercises, Katas
            Section(header: Text("Sections")) {
                // List Techniques
                NavigationLink(destination: SelectTechniquesView(session: $session, allTechniques: allTechniques)) {
                    HStack {
                        Text("Techniques")
                        Spacer()
                        Text("\(session.selectedTechniques.filter { $0.value }.count) Selected")
                    }
                }

                // List Exercises
                NavigationLink(destination: SelectExercisesView(session: $session, allExercises: allExercises)) {
                    HStack {
                        Text("Exercises")
                        Spacer()
                        Text("\(session.selectedExercises.filter { $0.value }.count) Selected")
                    }
                }

                // List Katas
                NavigationLink(destination: SelectKatasView(session: $session, allKatas: allKatas)) {
                    HStack {
                        Text("Katas")
                        Spacer()
                        Text("\(session.selectedKatas.filter { $0.value }.count) Selected")
                    }
                }
            }
        }
        .navigationTitle("Edit Session")
        .navigationBarItems(trailing: Button("Save") {
            saveModifications()
        })
        .onAppear {
            guard !isDataInitialized else { return }  // Ensure initialization happens only once
            isDataInitialized = true
            initializeData()
        }
    }

    // Function to initialize data
    private func initializeData() {
        print("Data initialized")
    }

    // Function to save modifications to Core Data
    private func saveModifications() {
        print("Attempting to save modifications to session: \(session.name)")
        
        // Fetch or create the TrainingSessionEntity from Core Data
        let sessionEntity: TrainingSessionEntity
        if let existingEntity = fetchTrainingSessionEntity(for: session.id) {
            sessionEntity = existingEntity
        } else {
            sessionEntity = TrainingSessionEntity(context: context)
            sessionEntity.id = session.id  // Assign the unique ID of the session
        }

        // Update session fields
        sessionEntity.name = session.name
        sessionEntity.timeBetweenTechniques = Int32(session.timeBetweenTechniques)

        // Remove existing sections before adding the new ones
        if let existingSections = sessionEntity.sections as? Set<TrainingSectionEntity> {
            for section in existingSections {
                context.delete(section)
            }
        }

        // Save the sections (techniques, exercises, katas)
        for section in session.sections {
            let sectionEntity = TrainingSectionEntity(context: context)
            sectionEntity.type = section.type.rawValue
            sectionEntity.id = UUID()  // Assign unique ID to each section

            // Save the items for each section
            for item in section.items {
                let itemEntity = TrainingItemEntity(context: context)
                itemEntity.id = item.id
                itemEntity.name = item.name
                itemEntity.category = item.category
                sectionEntity.addToItems(itemEntity)  // Add the item to the section
            }

            sessionEntity.addToSections(sectionEntity)  // Add the section to the session
        }

        // Save to Core Data
        do {
            try context.save()
            print("Successfully saved modified session.")
        } catch {
            print("Failed to save modified session: \(error)")
        }
    }

    // Helper function to fetch an existing TrainingSessionEntity from Core Data
    private func fetchTrainingSessionEntity(for id: UUID) -> TrainingSessionEntity? {
        let fetchRequest: NSFetchRequest<TrainingSessionEntity> = TrainingSessionEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1

        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch TrainingSessionEntity: \(error)")
            return nil
        }
    }
}
