//
//  SelectTrainingSessionView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/16/24.
//

import SwiftUI

struct SelectTrainingSessionView: View {
    @Binding var trainingSessions: [TrainingSession]  // Bind the list of training sessions
    @State private var selectedSession: TrainingSession?  // To store the selected session
    
    var body: some View {
        List {
            // Display available training sessions
            ForEach(trainingSessions) { session in
                Button(action: {
                    self.selectedSession = session
                }) {
                    HStack {
                        Text(session.name)
                        Spacer()
                        if selectedSession?.id == session.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Training Session")
    }
}

struct SelectTrainingSessionView_Previews: PreviewProvider {
    static var previews: some View {
        SelectTrainingSessionView(trainingSessions: .constant([]))  // Example usage
    }
}
