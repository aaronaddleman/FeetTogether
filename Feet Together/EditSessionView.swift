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

            Section(header: Text("Time Between Techniques (Seconds)")) {
                HStack {
                    Text("Time (seconds):")
                    Spacer()
                    TextField("Seconds", value: $session.timeBetweenTechniques, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .frame(width: 60)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section(header: Text("Settings")) {
                Toggle("Randomize Techniques", isOn: $session.randomizeTechniques)
            }

            Section(header: Text("Select Techniques")) {
                NavigationLink("Select Techniques", destination: SelectTechniquesView(session: $session, allTechniques: $allTechniques))
            }

            Section(header: Text("Select Exercises")) {
                NavigationLink("Select Exercises", destination: SelectExercisesView(session: $session, allExercises: $allExercises))
            }

            Section(header: Text("Select Katas")) {
                NavigationLink("Select Katas", destination: SelectKatasView(session: $session, allKatas: $allKatas))
            }
        }
        .navigationTitle("Edit Session")
    }
}
