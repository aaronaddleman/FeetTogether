//
//  AddTechniqueView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI

struct AddTechniqueView: View {
    @Binding var techniques: [AnyTrainingItem]  // Binding to the array of techniques
    @State private var techniqueName = ""
    @State private var techniqueCategory = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Technique Name")) {
                    TextField("Enter technique name", text: $techniqueName)
                }
                
                Section(header: Text("Category")) {
                    TextField("Enter category", text: $techniqueCategory)
                }
            }
            .navigationBarTitle("Add Technique", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()  // Dismiss the view without saving
                },
                trailing: Button("Save") {
                    addTechnique()  // Add the new technique and dismiss the view
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(techniqueName.isEmpty || techniqueCategory.isEmpty)  // Disable save if fields are empty
            )
        }
    }

    private func addTechnique() {
        // Create a new technique and add it to the techniques array
        let newTechnique = AnyTrainingItem(id: UUID(), name: techniqueName, category: techniqueCategory)
        techniques.append(newTechnique)
    }
}

