//
//  ExercisesView.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import SwiftUI

struct ExercisesView: View {
    @Binding var exercises: [Exercise]
    
    var body: some View {
        List {
            ForEach(exercises) { exercise in
                Text(exercise.name)
            }
        }
        .navigationTitle("Exercises")
    }
}

// Preview Provider (Optional)
struct ExercisesView_Previews: PreviewProvider {
    @State static var exercises = [
        Exercise(name: "Push-ups", category: "Strength"),
        Exercise(name: "Jumping Jacks", category: "Cardio")
    ]
    
    static var previews: some View {
        ExercisesView(exercises: $exercises)
    }
}
