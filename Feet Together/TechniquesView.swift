//
//  TechniquesView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import SwiftUI

struct TechniquesView: View {
    @Binding var techniques: [Technique]
    
    var body: some View {
        List {
            ForEach($techniques) { $technique in
                NavigationLink(destination: EditTechniqueView(technique: $technique)) {
                    Text(technique.name)
                }
            }
        }
        .navigationTitle("Techniques")
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
