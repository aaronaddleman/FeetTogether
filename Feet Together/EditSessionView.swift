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

    @Environment(\.managedObjectContext) private var context
    
    @State private var isDataInitialized = false // Flag to ensure initialization happens once

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

            Section(header: Text("Select Techniques")) {
                NavigationLink(destination: SelectTechniquesView(session: $session, allTechniques: allTechniques)) {
                    Text("Edit Techniques")
                }
            }

            Section(header: Text("Select Exercises")) {
                NavigationLink(destination: SelectExercisesView(session: $session, allExercises: allExercises)) {
                    Text("Edit Exercises")
                }
            }

            Section(header: Text("Select Katas")) {
                NavigationLink(destination: SelectKatasView(session: $session, allKatas: allKatas)) {
                    Text("Edit Katas")
                }
            }
        }
        .navigationTitle("Edit Session")
        .onAppear {
            guard !isDataInitialized else { return }  // Ensure initialization happens only once
            isDataInitialized = true
            initializeData()
        }
    }

    // Function to initialize data
    private func initializeData() {
        // Fetch or process data here, e.g., populate techniques, exercises, katas
        // If allTechniques, allExercises, allKatas require data from CoreData or an API, fetch them here.
        print("Data initialized")
    }
}
