//
//  SelectTrainingSessionView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/16/24.
//

import SwiftUI
import CoreData

struct SelectTrainingSessionView: View {
    @Environment(\.managedObjectContext) private var context

    // Fetch the training sessions from Core Data
    @FetchRequest(
        entity: TrainingSessionEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TrainingSessionEntity.name, ascending: true)]
    ) private var savedSessions: FetchedResults<TrainingSessionEntity>

    var body: some View {
        List {
            ForEach(savedSessions.indices, id: \.self) { index in
                NavigationLink(
                    destination: StartTrainingView(
                        sessionEntity: savedSessions[index]  // Pass Core Data session entity
                    )
                ) {
                    Text(savedSessions[index].name ?? "Unnamed Session")
                }
            }
        }
        .navigationTitle("Select Training Session")
    }

    // Helper function to convert Core Data entity to Swift model
    private func convertToTrainingSession(_ entity: TrainingSessionEntity) -> TrainingSession {
        var sections: [TrainingSection] = []
        
        // Map each Core Data section to the Swift TrainingSection model
        if let coreDataSections = entity.sections as? Set<TrainingSectionEntity> {
            for sectionEntity in coreDataSections {
                let items = (sectionEntity.items as? Set<TrainingItemEntity>)?.map { itemEntity in
                    AnyTrainingItem(id: itemEntity.id ?? UUID(), name: itemEntity.name ?? "Unnamed Item", category: itemEntity.category ?? "")
                } ?? []
                let section = TrainingSection(type: SectionType(rawValue: sectionEntity.type ?? "unknown") ?? .technique, items: items)
                sections.append(section)
            }
        }

        // Ensure session entity has a valid UUID or generate one if nil
        return TrainingSession(
            id: entity.id ?? UUID(),  // Use the new UUID field
            name: entity.name ?? "Unnamed",
            timeBetweenTechniques: Int(entity.timeBetweenTechniques),
            isFeetTogetherEnabled: entity.isFeetTogetherEnabled,
            randomizeTechniques: entity.randomizeTechniques,
            sections: sections
        )
    }
}
