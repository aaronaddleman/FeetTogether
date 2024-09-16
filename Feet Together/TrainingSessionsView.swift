//
//  TrainingSessionsView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import SwiftUI

// Predefined techniques, exercises, and katas initialization
let selectedTechniques = [
    predefinedTechniques[0],  // Kimono Grab
    predefinedTechniques[1],  // Eagles Beak A
    predefinedTechniques[2]   // Striking Asp B
].map { AnyTrainingItem($0) }

let customTechniquesSection = TrainingSection(
    type: .technique,
    items: selectedTechniques
)

let predefinedTrainingSessionWithThreeTechniques = TrainingSession(
    name: "Custom Session",
    timeBetweenTechniques: 10,
    isFeetTogetherEnabled: true,
    randomizeTechniques: false,
    sections: [customTechniquesSection]
)

let techniquesSectionBeginner = TrainingSection(
    type: SectionType.technique,
    items: predefinedTechniques.map { AnyTrainingItem($0) }
)

let exercisesSectionBeginner = TrainingSection(
    type: SectionType.exercise,
    items: predefinedExercises.map { AnyTrainingItem($0) }
)

let katasSectionBeginner = TrainingSection(
    type: SectionType.kata,
    items: predefinedKatas.map { AnyTrainingItem($0) }
)

let techniquesSectionAdvanced = TrainingSection(
    type: SectionType.technique,
    items: predefinedTechniques.map { AnyTrainingItem($0) }
)

let exercisesSectionAdvanced = TrainingSection(
    type: SectionType.exercise,
    items: predefinedExercises.map { AnyTrainingItem($0) }
)

let katasSectionAdvanced = TrainingSection(
    type: SectionType.kata,
    items: predefinedKatas.map { AnyTrainingItem($0) }
)

let predefinedTrainingSessions: [TrainingSession] = [
    TrainingSession(
        name: "Test Session",
        timeBetweenTechniques: 10,
        isFeetTogetherEnabled: false,
        randomizeTechniques: false,
        sections: [customTechniquesSection,
                   exercisesSectionBeginner,
                   katasSectionBeginner]
    ),
    TrainingSession(
        name: "Beginner Session",
        timeBetweenTechniques: 10,
        isFeetTogetherEnabled: false,
        randomizeTechniques: false,
        sections: [techniquesSectionBeginner, exercisesSectionBeginner, katasSectionBeginner]
    ),
    TrainingSession(
        name: "Advanced Session",
        timeBetweenTechniques: 15,
        isFeetTogetherEnabled: true,
        randomizeTechniques: true,
        sections: [techniquesSectionAdvanced, exercisesSectionAdvanced, katasSectionAdvanced]
    )
]

struct TrainingSessionsView: View {
    @Binding var trainingSessions: [TrainingSession]
    @State private var isDataInitialized = false  // Flag to guard initialization

    var body: some View {
        NavigationView {
            List {
                ForEach(trainingSessions.indices, id: \.self) { index in  // Use indices to access each session
                    NavigationLink(
                        destination: StartTrainingView(session: trainingSessions[index])  // Pass session, no binding needed
                    ) {
                        Text(trainingSessions[index].name)
                    }
                }
                .onDelete { indexSet in
                    trainingSessions.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("Training Sessions")
        }
        .onAppear {
            guard !isDataInitialized else { return }  // Ensure initialization happens only once
            isDataInitialized = true
            initializeTrainingSessions()
        }
    }

    // Function to initialize predefined training sessions if needed
    private func initializeTrainingSessions() {
        // If the list of training sessions is empty, populate it with the predefined sessions
        if trainingSessions.isEmpty {
            trainingSessions = predefinedTrainingSessions
            print("Initialized training sessions.")
        }
    }
}
