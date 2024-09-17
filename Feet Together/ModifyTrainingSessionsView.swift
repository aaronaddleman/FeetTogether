//
//  ModifyTrainingSessionsView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import SwiftUI
import CoreData

struct ModifyTrainingSessionsView: View {
    @FetchRequest(
        entity: TrainingSessionEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TrainingSessionEntity.name, ascending: true)]
    ) private var savedSessions: FetchedResults<TrainingSessionEntity>  // Fetch data from Core Data

    @Binding var allTechniques: [Technique]
    @Binding var allExercises: [Exercise]
    @Binding var allKatas: [Kata]

    @Environment(\.managedObjectContext) private var context

    var body: some View {
        List {
            ForEach(savedSessions, id: \.self) { sessionEntity in
                NavigationLink(destination: EditSessionView(
                    session: .constant(convertToTrainingSession(sessionEntity)),
                    allTechniques: $allTechniques,
                    allExercises: $allExercises,
                    allKatas: $allKatas
                )) {
                    Text(sessionEntity.name ?? "Unnamed Session")
                }
            }
            .onDelete(perform: deleteSession)
        }
        .navigationTitle("Modify Training Sessions")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: addNewSession) {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            print("onAppear: Current training sessions count: \(savedSessions.count)")
        }
    }

    // Add a new session and save it to Core Data
    private func addNewSession() {
        let newSession = TrainingSessionEntity(context: context)
        newSession.id = UUID()  // Ensure unique identifier
        newSession.name = "New Session"
        newSession.timeBetweenTechniques = 10

        // Save the new session to Core Data
        do {
            try context.save()
            print("New session added: \(newSession.name ?? "Unnamed")")
        } catch {
            print("Failed to add new session: \(error)")
        }

        print("after addNewSession: Current training sessions count: \(savedSessions.count)")
    }

    // Convert Core Data entity to Swift model
    private func convertToTrainingSession(_ entity: TrainingSessionEntity) -> TrainingSession {
        var sections: [TrainingSection] = []
        if let coreDataSections = entity.sections as? Set<TrainingSectionEntity> {
            for sectionEntity in coreDataSections {
                let items = (sectionEntity.items as? Set<TrainingItemEntity>)?.map { itemEntity in
                    AnyTrainingItem(id: itemEntity.id ?? UUID(), name: itemEntity.name ?? "Unnamed Item", category: itemEntity.category ?? "")
                } ?? []
                let section = TrainingSection(type: SectionType(rawValue: sectionEntity.type ?? "unknown") ?? .technique, items: items)
                sections.append(section)
            }
        }

        return TrainingSession(
            name: entity.name ?? "Unnamed",
            timeBetweenTechniques: Int(entity.timeBetweenTechniques),
            isFeetTogetherEnabled: entity.isFeetTogetherEnabled,
            randomizeTechniques: entity.randomizeTechniques,
            sections: sections
        )
    }

    // Delete a session from Core Data
    private func deleteSession(at offsets: IndexSet) {
        offsets.map { savedSessions[$0] }.forEach(context.delete)

        // Save changes to Core Data
        do {
            try context.save()
            print("Session deleted.")
        } catch {
            print("Failed to delete session: \(error)")
        }
    }
}
