//
//  TrainingSessionsView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import SwiftUI

struct TrainingSessionsView: View {
    @Binding var trainingSessions: [TrainingSession]
    @Binding var allTechniques: [Technique]
    @State private var selectedSession: TrainingSession?

    var body: some View {
        List {
            // Display available training sessions
            ForEach(trainingSessions) { session in
                NavigationLink(
                    destination: StartTrainingView(trainingSessions: [session]),
                    tag: session,
                    selection: $selectedSession  // Bind selection to selectedSession
                ) {
                    Text(session.name)
                        .font(.headline)
                        .padding()
                }
            }
        }
        .navigationTitle("Training Sessions")
        .onAppear {
            print("Total sessions available: \(trainingSessions.count)")
        }
    }
}
