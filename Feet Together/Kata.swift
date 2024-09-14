//
//  Kata.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import Foundation

struct Kata: TrainingItem, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var category: String
    
    // Manually conform to Equatable
    static func == (lhs: Kata, rhs: Kata) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}

let predefinedKatas = [
    Kata(name: "Kata 1 Left Side", category: "White"),
    Kata(name: "Kata 1 Right Side", category: "White")
]
