//
//  TechniquesView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import SwiftUI
import CoreData

struct TechniquesView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: TechniqueEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TechniqueEntity.name, ascending: true)]
    ) private var allTechniques: FetchedResults<TechniqueEntity>

    @State private var selectedTechnique: TechniqueEntity?

    var body: some View {
        NavigationView {
            List {
                ForEach(allTechniques, id: \.self) { technique in
                    NavigationLink(
                        destination: EditTechniqueView(technique: Binding($selectedTechnique, technique)),
                        tag: technique,
                        selection: $selectedTechnique
                    ) {
                        Text(technique.name ?? "Unnamed Technique")
                    }
                }
                .onDelete(perform: deleteTechnique)
            }
            .navigationTitle("Techniques")
            .navigationBarItems(trailing: Button(action: {
                addNewTechnique()
            }) {
                Image(systemName: "plus")
            })
        }
    }

    // Add a new technique
    private func addNewTechnique() {
        let newTechnique = TechniqueEntity(context: context)
        newTechnique.id = UUID()  // Ensure unique identifier
        newTechnique.name = "New Technique"  // Set default name
        newTechnique.category = "General"  // Set default category

        // Save the new technique to Core Data
        do {
            try context.save()
            print("Successfully added new technique.")
        } catch {
            print("Failed to add new technique: \(error)")
        }
    }

    // Delete a technique from Core Data
    private func deleteTechnique(at offsets: IndexSet) {
        offsets.map { allTechniques[$0] }.forEach(context.delete)

        // Save changes to Core Data
        do {
            try context.save()
            print("Successfully deleted technique.")
        } catch {
            print("Failed to delete technique: \(error)")
        }
    }
}
