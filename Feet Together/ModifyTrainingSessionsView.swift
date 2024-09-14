//
//  ModifyTrainingSessionsView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import SwiftUI

struct ModifyTrainingSessionsView: View {
    @Binding var trainingSessions: [TrainingSession]
    @Binding var allTechniques: [Technique]
    @Binding var allExercises: [Exercise]
    @Binding var allKatas: [Kata]
    
    var body: some View {
        List {
            ForEach($trainingSessions) { $session in
                NavigationLink(destination: EditSessionView(
                    session: $session,
                    allTechniques: $allTechniques,
                    allExercises: $allExercises,
                    allKatas: $allKatas
                )) {
                    Text(session.name)
                }
            }
        }
        .navigationTitle("Modify Training Sessions")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: addNewSession) {
                    Image(systemName: "plus")
                }
            }
        }
    }

    // Add a new session with the correct argument order for TrainingSession
    private func addNewSession() {
        let newSession = TrainingSession(
            name: "New Session",
            timeBetweenTechniques: 10,
            isFeetTogetherEnabled: false,
            randomizeTechniques: false,
            sections: []
        )
        trainingSessions.append(newSession)
    }
}
