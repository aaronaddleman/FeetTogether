//
//  ContentView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

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
        sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseEntity.name,
                                          ascending: true)]
    ) private var allExercises: FetchedResults<ExerciseEntity>
    
    @State private var trainingSessions: [TrainingSession] = []
    @State private var techniques: [Technique] = []
    @State private var exercises: [Exercise] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Main Menu")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Navigate to SelectTrainingSessionView
                NavigationLink(
                    destination: SelectTrainingSessionView(trainingSessions: $trainingSessions)  // Pass the binding
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
                        trainingSessions: $trainingSessions,  // Pass a binding to the state
                        allTechniques: $techniques
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
                NavigationLink(destination: TechniquesView()) {
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
            .onAppear {
                loadTrainingSessions()
            }
        }
    }

    // Helper function to load and convert Core Data sessions to Swift models
    private func loadTrainingSessions() {
        // Explicit type annotation to avoid ambiguity
        let sessionsArray: [TrainingSession] = savedSessions.map { entity in
            return convertToTrainingSession(entity)
        }
        trainingSessions = sessionsArray

        let techniquesArray: [Technique] = allTechniques.map { entity in
            return Technique(from: entity)
        }
        
        let exercisesArray: [Exercise] = allExercises.map { entity in
            return Exercise(from: entity)
        }
        techniques = techniquesArray
        exercises = exercisesArray
    }

    // Helper function to convert Core Data session to Swift model
    private func convertToTrainingSession(_ entity: TrainingSessionEntity) -> TrainingSession {
        let techniquesArray: [Technique] = (entity.selectedTechniques?.allObjects as? [TechniqueEntity])?.map { techniqueEntity in
            return Technique(from: techniqueEntity)
        } ?? []
        
        // Convert exercises from Core Data to Swift model
        let exercisesArray: [Exercise] = (entity.selectedExercises?.allObjects as? [ExerciseEntity])?.map { exerciseEntity in
            return Exercise(from: exerciseEntity)
        } ?? []
        
        let katasArray: [Kata] = (entity.selectedKatas?.allObjects as? [KataEntity])?.map { kataEntity in
            return Kata(from: kataEntity)
        } ?? []
        
        return TrainingSession(
            name: entity.name ?? "Unnamed",
            techniques: techniquesArray,
            exercises: exercisesArray,
            katas: katasArray,
            timeBetweenTechniques: Int(entity.timeBetweenTechniques),
            isFeetTogetherEnabled: entity.isFeetTogetherEnabled,
            randomizeTechniques: entity.randomizeTechniques
        )
    }
}
