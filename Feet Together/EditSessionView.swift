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
    
    var body: some View {
        Form {
            // Session Name Section
            Section(header: Text("Session Name")) {
                TextField("Session Name", text: $session.name)
            }
            
            // Timer Duration Section
            Section(header: Text("Set Time Between Techniques")) {
                HStack {
                    Text("Time (seconds):")
                    Spacer()
                    TextField("Seconds", value: $session.timeBetweenTechniques, format: .number)
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                        .multilineTextAlignment(.trailing)
                }
            }
                        
            // Settings for Feet Together
            Section(header: Text("Settings")) {
                Toggle("Enable 'Feet Together'", isOn: $session.isFeetTogetherEnabled)
            }
            
            // Randomize Techniques Toggle
            Section(header: Text("Randomize Techniques")) {
                Toggle("Randomize Techniques", isOn: $session.randomizeTechniques)
            }
            
            // Selected Techniques Section
            Section(header: Text("Selected Techniques")) {
                List {
                    ForEach(session.techniques) { technique in
                        HStack {
                            Text(technique.name)
                            Spacer()
                            Text(technique.category)
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete(perform: removeSelectedTechnique)
                }
            }
            
            // Available Techniques Section
            Section(header: Text("Available Techniques")) {
                List(allTechniques) { technique in
                    HStack {
                        Text(technique.name)
                        Spacer()
                        Text(technique.category)
                            .foregroundColor(.gray)
                        
                        if session.techniques.contains(where: { $0.id == technique.id }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                    .contentShape(Rectangle()) // Makes the entire row tappable
                    .onTapGesture {
                        toggleTechniqueSelection(technique)
                    }
                }
            }
            

        }
        .navigationTitle("Edit \(session.name)")
    }
    
    // Toggle technique selection
    private func toggleTechniqueSelection(_ technique: Technique) {
        if let index = session.techniques.firstIndex(where: { $0.id == technique.id }) {
            session.techniques.remove(at: index)
        } else {
            session.techniques.append(technique)
        }
    }
    
    // Remove a technique from the selected list
    private func removeSelectedTechnique(at offsets: IndexSet) {
        session.techniques.remove(atOffsets: offsets)
    }
}



// Assuming this struct is already in your code
struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
