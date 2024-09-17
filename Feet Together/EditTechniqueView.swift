//
//  EditTechniqueView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/16/24.
//

import SwiftUI
import CoreData

struct EditTechniqueView: View {
    @Binding var technique: TechniqueEntity
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        Form {
            Section(header: Text("Technique Name")) {
                TextField("Technique Name", text: Binding($technique.name, "Unnamed Technique"))
            }

            Section(header: Text("Technique Category")) {
                TextField("Technique Category", text: Binding($technique.category, "General"))
            }
        }
        .navigationTitle("Edit Technique")
        .navigationBarItems(trailing: Button("Save") {
            saveTechnique()
        })
    }

    // Save changes to Core Data
    private func saveTechnique() {
        do {
            try context.save()
            print("Successfully saved technique.")
        } catch {
            print("Failed to save technique: \(error)")
        }
    }
}

// Helper extension for handling nil values in bindings
extension Binding {
    init(_ source: Binding<Value?>, _ defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { newValue in source.wrappedValue = newValue }
        )
    }
}
