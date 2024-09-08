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

    var body: some View {
        // Example UI for modifying training sessions
        List {
            ForEach($trainingSessions) { $session in
                NavigationLink(destination: EditSessionView(session: $session, allTechniques: $allTechniques)) {
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
    
    private func addNewSession() {
        let newSession = TrainingSession(name: "New Session", techniques: [])
        trainingSessions.append(newSession)
    }
}
