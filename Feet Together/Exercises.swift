//
//  Exercises.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import Foundation

struct Exercise: TrainingItem, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var category: String
    
    // Manually conform to Equatable
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}

let predefinedExercises = [
    Exercise(name: "Burpees", category: "White"),
    Exercise(name: "Frog to Knee Ups", category: "White"),
    Exercise(name: "Leg Lifts", category: "White")
]
