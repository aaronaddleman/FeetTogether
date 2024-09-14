import SwiftUI

struct ContentView: View {
    @State private var trainingSessions: [TrainingSession] = predefinedTrainingSessions
    @State private var techniques: [Technique] = predefinedTechniques
    @State private var exercises: [Exercise] = predefinedExercises
    @State private var katas: [Kata] = predefinedKatas
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Main Menu")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
    
                // Navigate to session selection
                NavigationLink(
                    destination: TrainingSessionsView(
                        trainingSessions: $trainingSessions,
                        allTechniques: $techniques,
                        allExercises: $exercises,
                        allKatas: $katas
                    )
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
                        trainingSessions: $trainingSessions,
                        allTechniques: $techniques,
                        allExercises: $exercises,
                        allKatas: $katas
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
    
                // Navigate to Techniques View
                NavigationLink(destination: TechniquesView(techniques: $techniques)) {
                    Text("Techniques")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Navigate to Exercises View
                NavigationLink(destination: ExercisesView(exercises: $exercises)) {
                    Text("Exercises")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Navigate to Katas View
                NavigationLink(destination: KatasView(katas: $katas)) {
                    Text("Katas")
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
}
