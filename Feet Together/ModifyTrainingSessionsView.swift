//
//  ModifyTrainingSessionsView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import SwiftUI

struct ModifyTrainingSessionsView: View {
    @Binding var trainingSessions: [TrainingSession]

    var body: some View {
        NavigationView {
            List {
                ForEach($trainingSessions) { $session in
                    NavigationLink(
                        destination: EditSessionView(session: $session) // No need for techniques, exercises, or katas
                    ) {
                        Text(session.name)
                    }
                }
                .onDelete { indexSet in
                    trainingSessions.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("Modify Training Sessions")
            .toolbar {
                Button(action: addNewSession) {
                    Image(systemName: "plus")
                }
            }
        }
    }

    private func addNewSession() {
        let newSession = TrainingSession(
            name: "New Session",
            timeBetweenTechniques: 10,
            isFeetTogetherEnabled: true,
            randomizeTechniques: false,
            sections: []  // Empty sections, user will fill them later
        )
        trainingSessions.append(newSession)
    }
}
