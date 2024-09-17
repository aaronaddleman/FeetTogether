import SwiftUI
import CoreData

struct TrainingSessionsView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: TrainingSessionEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TrainingSessionEntity.name, ascending: true)]
    ) private var savedSessions: FetchedResults<TrainingSessionEntity>  // Fetch data from Core Data

    @State private var allTechniques: [Technique] = []
    @State private var allExercises: [Exercise] = []
    @State private var allKatas: [Kata] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(savedSessions.indices, id: \.self) { index in
                    // Create a NavigationLink to StartTrainingView
                    NavigationLink(
                        destination: StartTrainingView(
                            sessionEntity: savedSessions[index]  // Pass the Core Data entity directly
                        )
                    ) {
                        Text(savedSessions[index].name ?? "Unnamed Session")
                    }
                }
                .onDelete(perform: deleteSession)
            }
            .navigationTitle("Training Sessions")
            .navigationBarItems(trailing: Button(action: {
                addNewSession()
            }) {
                Image(systemName: "plus")
            })
        }
    }

    // Add a new session (empty session)
    private func addNewSession() {
        let newSession = TrainingSessionEntity(context: context)
        newSession.id = UUID()  // Ensure a unique identifier is set
        newSession.name = "New Session"
        newSession.timeBetweenTechniques = 10

        // Save the new session to Core Data
        do {
            try context.save()
            print("Successfully added new session.")
        } catch {
            print("Failed to add new session: \(error)")
        }
    }

    // Delete a session from Core Data
    private func deleteSession(at offsets: IndexSet) {
        offsets.map { savedSessions[$0] }.forEach(context.delete)

        // Save changes to Core Data
        do {
            try context.save()
            print("Successfully deleted session.")
        } catch {
            print("Failed to delete session: \(error)")
        }
    }
}
