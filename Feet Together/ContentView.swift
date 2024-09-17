import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: TrainingSessionEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TrainingSessionEntity.name, ascending: true)]
    ) private var savedSessions: FetchedResults<TrainingSessionEntity>  // Fetch data from Core Data

    @FetchRequest(
        entity: TechniqueEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TechniqueEntity.name, ascending: true)]
    ) private var allTechniques: FetchedResults<TechniqueEntity>
    
    @FetchRequest(
        entity: ExerciseEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseEntity.name, ascending: true)]
    ) private var allExercises: FetchedResults<ExerciseEntity>
    
    @FetchRequest(
        entity: KataEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \KataEntity.name, ascending: true)]
    ) private var allKatas: FetchedResults<KataEntity>

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Main Menu")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Navigate to SelectTrainingSessionView
                NavigationLink(
                    destination: SelectTrainingSessionView()
                ) {
                    Text("Start Training")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Navigate to Modify Training Sessions
                NavigationLink(
                    destination: ModifyTrainingSessionsView(
                        allTechniques: .constant(allTechniques.map {
                            Technique(id: $0.id ?? UUID(), name: $0.name ?? "", category: $0.category ?? "")
                        }),
                        allExercises: .constant(allExercises.map {
                            Exercise(id: $0.id ?? UUID(), name: $0.name ?? "", category: $0.category ?? "")
                        }),
                        allKatas: .constant(allKatas.map {
                            Kata(id: $0.id ?? UUID(), name: $0.name ?? "", category: "nothing")
                        })
                    )
                ) {
                    Text("Modify Training Sessions")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Navigate to Techniques View (no arguments needed)
                NavigationLink(destination: TechniquesView()) {
                    Text("Techniques")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Navigate to Exercises View
                NavigationLink(destination: ExercisesView(exercises: .constant(allExercises.map {
                    Exercise(id: $0.id ?? UUID(), name: $0.name ?? "", category: $0.category ?? "")
                }))) {
                    Text("Exercises")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Navigate to Katas View
                NavigationLink(destination: KatasView(katas: .constant(allKatas.map {
                    Kata(id: $0.id ?? UUID(), name: $0.name ?? "", category: "nothing")
                }))) {
                    Text("Katas")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Button to delete all data
                Button(action: deleteAllData) {
                    Text("Delete All Data")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Feet Together")
        }
    }

    // Function to delete all data from Core Data
    private func deleteAllData() {
        let fetchRequests: [NSFetchRequest<NSFetchRequestResult>] = [
            TrainingSessionEntity.fetchRequest(),
            TechniqueEntity.fetchRequest(),
            ExerciseEntity.fetchRequest(),
            KataEntity.fetchRequest()
        ]

        do {
            for request in fetchRequests {
                let entities = try context.fetch(request)
                for entity in entities {
                    context.delete(entity as! NSManagedObject)
                }
            }

            try context.save()
            print("Successfully deleted all data.")
        } catch {
            print("Failed to delete data: \(error)")
        }
    }
}
