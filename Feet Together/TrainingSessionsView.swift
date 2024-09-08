//
//  TrainingSessionsView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import SwiftUI

let predefinedTrainingSessions: [TrainingSession] = [
    TrainingSession(
        name: "Beginner Session",
        techniques: [predefinedTechniques[0], predefinedTechniques[1]],
        timeBetweenTechniques: 10,
        isFeetTogetherEnabled: false,
        randomizeTechniques: false
    ),
    TrainingSession(
        name: "Advanced Session",
        techniques: [predefinedTechniques[2], predefinedTechniques[3]],
        timeBetweenTechniques: 15,
        isFeetTogetherEnabled: true,
        randomizeTechniques: true
    )
]

struct TrainingSessionsView: View {
    @Binding var trainingSessions: [TrainingSession]
    @Binding var allTechniques: [Technique]
    @State private var selectedSession: TrainingSession?

    var body: some View {
        List {
            // Display available training sessions
            ForEach(trainingSessions) { session in
                NavigationLink(destination: StartTrainingView(trainingSessions: [session])) {
                    Text(session.name)
                }
            }
        }
        .navigationTitle("Training Sessions")
    }
}
