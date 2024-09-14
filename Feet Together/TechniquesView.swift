//
//  TechniquesView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import SwiftUI

struct TechniquesView: View {
    @Binding var techniques: [Technique]
    @State private var showingAddTechnique = false  // Control the sheet presentation

    var body: some View {
        List {
            ForEach($techniques) { $technique in
                NavigationLink(destination: EditTechniqueView(technique: $technique)) {
                    Text(technique.name)
                }
            }
        }
        .navigationTitle("Techniques")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddTechnique.toggle()  // Present the add technique view
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTechnique) {
            AddTechniqueView(techniques: Binding(get: {
                // Convert `Technique` array to `AnyTrainingItem` array for AddTechniqueView
                techniques.map { AnyTrainingItem(id: $0.id, name: $0.name, category: $0.category) }
            }, set: { newTechniques in
                // Convert `AnyTrainingItem` array back to `Technique` array after adding a new one
                techniques = newTechniques.map { Technique(id: $0.id, name: $0.name, category: $0.category) }
            }))
        }
    }
}


struct EditTechniqueView: View {
    @Binding var technique: Technique

    var body: some View {
        Form {
            Section(header: Text("Edit Technique")) {
                TextField("Technique Name", text: $technique.name)
                TextField("Category", text: $technique.category)
            }
        }
        .navigationTitle("Edit Technique")
    }
}
