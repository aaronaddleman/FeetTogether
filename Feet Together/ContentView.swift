//
//  ContentView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//


import SwiftUI

struct ContentView: View {
    @State private var trainingSessions: [TrainingSession] = predefinedTrainingSessions
    @State private var techniques: [Technique] = predefinedTechniques
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Main Menu")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Navigate to session selection
                NavigationLink(destination: TrainingSessionsView(trainingSessions: $trainingSessions, allTechniques: $techniques)) {
                    Text("Start Training")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Navigate to Modify Training Sessions, passing trainingSessions and techniques
                NavigationLink(destination: ModifyTrainingSessionsView(trainingSessions: $trainingSessions, allTechniques: $techniques)) {
                    Text("Modify Training Sessions")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Navigate to Techniques View, passing techniques
                NavigationLink(destination: TechniquesView(techniques: $techniques)) {
                    Text("Techniques")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
            }
            .padding()
            .navigationTitle("Feet Together")
        }
    }
}
