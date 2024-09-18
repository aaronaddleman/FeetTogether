//
//  ModifyTrainingSessionsView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import SwiftUI
import CoreData

struct ModifyTrainingSessionsView: View {
    @Binding var trainingSessions: [TrainingSession]
    @Binding var allTechniques: [Technique]
    
    @Environment(\.managedObjectContext) private var context  // Use Core Data's managed object context

    var body: some View {
        List {
            ForEach($trainingSessions) { $session in
                NavigationLink(destination: EditSessionView(session: $session, allTechniques: $allTechniques)) {
                    Text(session.name)
                }
            }
            .onDelete { indexSet in
                deleteSession(at: indexSet)  // Deletes from Core Data as well
            }
        }
        .navigationTitle("Modify Training Sessions")
        .toolbar {
            Button(action: {
                            addNewSession(context: context)  // Pass the context in the closure
                        }) {
                            Image(systemName: "plus")
                        }
        }
        .onAppear {
            fetchTrainingSessionsFromCoreData()
        }
        .onDisappear {
            print("Modify Training Sessions View disappeared. Number of training sessions: \(trainingSessions.count)")
        }
    }

    // Fetch sessions from Core Data
    private func fetchTrainingSessionsFromCoreData() {
        let fetchRequest: NSFetchRequest<TrainingSessionEntity> = TrainingSessionEntity.fetchRequest()
        
        do {
            let coreDataSessions = try context.fetch(fetchRequest)
            self.trainingSessions = coreDataSessions.map { TrainingSession(from: $0) }  // Use the new initializer
            print("Fetched \(coreDataSessions.count) training sessions from Core Data.")
        } catch {
            print("Error fetching training sessions from Core Data: \(error)")
        }
    }

    // Function to delete a session from both the UI and Core Data
    private func deleteSession(at offsets: IndexSet) {
        offsets.forEach { index in
            let sessionToDelete = trainingSessions[index]
            
            // Delete from Core Data
            let fetchRequest: NSFetchRequest<TrainingSessionEntity> = TrainingSessionEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", sessionToDelete.id as CVarArg)
            
            do {
                let fetchedSessions = try context.fetch(fetchRequest)
                if let entityToDelete = fetchedSessions.first {
                    context.delete(entityToDelete)
                }
                
                try context.save()  // Save Core Data after deletion
            } catch {
                print("Error deleting session from Core Data: \(error)")
            }
            
            // Remove from the local array
            trainingSessions.remove(at: index)
        }
    }

    // Function to save a new session to Core Data
    private func addNewTrainingSession(context: NSManagedObjectContext, session: TrainingSession) {
        let newSessionEntity = TrainingSessionEntity(context: context)
        newSessionEntity.id = session.id
        newSessionEntity.name = session.name
        newSessionEntity.timeBetweenTechniques = Int32(session.timeBetweenTechniques)
        newSessionEntity.isFeetTogetherEnabled = session.isFeetTogetherEnabled
        newSessionEntity.randomizeTechniques = session.randomizeTechniques
        
        do {
            try context.save()
            print("New session saved to Core Data")
        } catch {
            print("Error saving session: \(error.localizedDescription)")
        }
    }

    // Function to add a new session to the trainingSessions array and save it to Core Data
    private func addNewSession(context: NSManagedObjectContext) {
        let newSession = TrainingSession(
            id: UUID(),
            name: "New Session",
            techniques: [],
            exercises: [],
            katas: [],
            timeBetweenTechniques: 10,
            isFeetTogetherEnabled: false,
            randomizeTechniques: false
        )
        
        // Append the session to the local array (for UI purposes)
        trainingSessions.append(newSession)
        
        // Call the helper function to save the session to Core Data
        addNewTrainingSession(context: context, session: newSession)
    }

    // Save Core Data context
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
