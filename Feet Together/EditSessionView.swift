//
//  EditSessionView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import SwiftUI

struct EditSessionView: View {
    @Binding var session: TrainingSession
    @Binding var allTechniques: [Technique]
    @Binding var allExercises: [Exercise]
    @Binding var allKatas: [Kata]

    var body: some View {
        Form {
            Section(header: Text("Session Name")) {
                TextField("Session Name", text: $session.name)
            }

            Section(header: Text("Set Time Between Techniques")) {
                HStack {
                    Text("Time (seconds):")
                    Spacer()
                    TextField("Seconds", value: $session.timeBetweenTechniques, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section(header: Text("Settings")) {
                Toggle("Enable 'Feet Together'", isOn: $session.isFeetTogetherEnabled)
                Toggle("Randomize Techniques", isOn: $session.randomizeTechniques)
            }

            // Navigate to Edit Techniques View
            Section {
                NavigationLink(destination: EditTechniquesView(session: $session, allTechniques: $allTechniques)) {
                    Text("Edit Techniques")
                }
            }

            // Navigate to Edit Exercises View
            Section {
                NavigationLink(destination: EditExercisesView(session: $session, allExercises: $allExercises)) {
                    Text("Edit Exercises")
                }
            }

            // Navigate to Edit Katas View
            Section {
                NavigationLink(destination: EditKatasView(session: $session, allKatas: $allKatas)) {
                    Text("Edit Katas")
                }
            }
        }
        .navigationTitle("Edit \(session.name)")
    }
}
