//
//  EditSessionView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import SwiftUI

struct EditSessionView: View {
    @Binding var session: TrainingSession  // No need to pass separate allTechniques, allExercises, allKatas

    var body: some View {
        Form {
            // Session name
            Section(header: Text("Session Name")) {
                TextField("Enter session name", text: $session.name)
            }

            // Time between techniques
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

            // Randomize techniques toggle
            Section(header: Text("Randomize Techniques")) {
                Toggle("Randomize Techniques", isOn: $session.randomizeTechniques)
            }

            // Reorder sections: Techniques, Exercises, Katas
            Section(header: Text("Reorder Sections")) {
                EditButton()
                List {
                    ForEach($session.sections) { $section in
                        HStack {
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(.gray)
                            Text(section.type.rawValue)
                        }
                    }
                    .onMove { indices, newOffset in
                        session.sections.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
            }

            // Navigate to Edit Sections (Techniques, Exercises, Katas)
            Section(header: Text("Edit Sections")) {
                NavigationLink("Edit Techniques", destination: EditTechniquesView(session: $session))
                NavigationLink("Edit Exercises", destination: EditExercisesView(session: $session))
                NavigationLink("Edit Katas", destination: EditKatasView(session: $session))
            }
        }
        .navigationTitle("Edit \(session.name)")
    }
}
