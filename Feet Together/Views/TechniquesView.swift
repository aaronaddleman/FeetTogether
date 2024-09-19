//
//  TechniquesView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import SwiftUI
import CoreData

import SwiftUI
import CoreData

struct TechniquesView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: TechniqueEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TechniqueEntity.name, ascending: true)]
    ) private var fetchedTechniques: FetchedResults<TechniqueEntity>
    @State private var isAddingOrEditingTechnique = false
    @State private var isEditingTechnique = false
    @State private var selectedTechnique: TechniqueEntity?
    @State private var newTechniqueName = ""
    @State private var newTechniqueCategory = "General"

    var body: some View {
        VStack {
            List {
                ForEach(fetchedTechniques, id: \.self) { technique in
                    Button(action: {
                        // Populate the technique details for editing
                        selectedTechnique = technique
                        newTechniqueName = technique.name ?? ""
                        newTechniqueCategory = technique.category ?? "General"
                        isEditingTechnique = true
                        isAddingOrEditingTechnique = true
                    }) {
                        Text(technique.name ?? "Unnamed Technique")
                    }
                }
                .onDelete(perform: deleteTechnique)
            }

            Button(action: {
                // Clear fields for adding a new technique
                selectedTechnique = nil
                newTechniqueName = ""
                newTechniqueCategory = "General"
                isEditingTechnique = false
                isAddingOrEditingTechnique = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Technique")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Techniques")
        .sheet(isPresented: $isAddingOrEditingTechnique) {
            AddNewOrEditTechniqueView(
                newTechniqueName: $newTechniqueName,
                newTechniqueCategory: $newTechniqueCategory,
                onSave: {
                    if isEditingTechnique {
                        updateExistingTechnique()
                    } else {
                        addNewTechnique()
                    }
                },
                onCancel: {
                    isAddingOrEditingTechnique = false
                }
            )
        }
    }

    // Add a new technique to Core Data
    private func addNewTechnique() {
        let newTechnique = TechniqueEntity(context: context)
        newTechnique.id = UUID()
        newTechnique.name = newTechniqueName
        newTechnique.category = newTechniqueCategory

        do {
            try context.save()
            print("New technique saved to Core Data.")
        } catch {
            print("Failed to save new technique: \(error)")
        }

        // Reset state
        newTechniqueName = ""
        newTechniqueCategory = "General"
        isAddingOrEditingTechnique = false
    }

    // Update an existing technique in Core Data
    private func updateExistingTechnique() {
        if let selectedTechnique = selectedTechnique {
            selectedTechnique.name = newTechniqueName
            selectedTechnique.category = newTechniqueCategory

            do {
                try context.save()
                print("Technique updated.")
            } catch {
                print("Failed to update technique: \(error)")
            }
        }

        // Reset state
        newTechniqueName = ""
        newTechniqueCategory = "General"
        isAddingOrEditingTechnique = false
    }

    // Delete a technique from Core Data
    private func deleteTechnique(at offsets: IndexSet) {
        for index in offsets {
            let techniqueToDelete = fetchedTechniques[index]
            context.delete(techniqueToDelete)
        }

        do {
            try context.save()
            print("Technique deleted.")
        } catch {
            print("Failed to delete technique: \(error)")
        }
    }
}

struct AddNewOrEditTechniqueView: View {
    @Binding var newTechniqueName: String
    @Binding var newTechniqueCategory: String
    @FocusState private var isNameFocused: Bool
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Technique Name", text: $newTechniqueName)
                    .focused($isNameFocused)
                    .onAppear {
                        // Delay ensures focus happens after the view is fully rendered
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isNameFocused = true // Focus on the name field when the view appears
                        }
                    }
                    .onSubmit {
                        validateTechniqueName()
                    }

                TextField("Category", text: $newTechniqueCategory)
            }
            .navigationTitle("Add/Edit Technique")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if validateTechniqueName() {
                            onSave()
                        }
                    }
                }
            }
        }
    }

    private func validateTechniqueName() -> Bool {
        if newTechniqueName.trimmingCharacters(in: .whitespaces).isEmpty {
            print("Cannot save an empty technique name.")
            return false
        }
        return true
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
