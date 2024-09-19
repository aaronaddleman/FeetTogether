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
        NavigationStack {
            List {
                // Display available training sessions
                ForEach(trainingSessions, id: \.id) { session in
                    NavigationLink(value: session) {
                        Text(session.name)
                            .font(.headline)
                            .padding()
                    }
                }
                .onDelete { indexSet in
                    deleteSession(at: indexSet)
                }
            }
            .navigationTitle("Training Sessions")
            .toolbar {
                Button(action: addNewSession) {
                    Image(systemName: "plus")
                }
            }
            .navigationDestination(for: TrainingSession.self) { session in
                StartTrainingView(trainingSessions: [session])
            }
            .onAppear {
                print("Total sessions available: \(trainingSessions.count)")
            }
        }
    }

    private func deleteSession(at offsets: IndexSet) {
        print("delete session activated")
    }

    private func addNewSession() {
        print("add new session activated")
    }
}
