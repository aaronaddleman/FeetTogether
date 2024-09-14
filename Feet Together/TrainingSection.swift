//
//  TrainingSection.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/13/24.
//

import Foundation

struct TrainingSection: Identifiable {
    var id = UUID()
    var type: SectionType
    var items: [AnyTrainingItem]
}

enum SectionType: String, CaseIterable, Identifiable {
    case technique = "Techniques"
    case exercise = "Exercises"
    case kata = "Katas"
    
    var id: String { self.rawValue }
}

protocol TrainingItem: Identifiable {
    var id: UUID { get }
    var name: String { get }
    var category: String { get }
}


struct AnyTrainingItem: Identifiable, Equatable {
    var id: UUID
    var name: String
    var category: String
    
    init(_ technique: Technique) {
        self.id = technique.id
        self.name = technique.name
        self.category = technique.category
    }

    init(_ exercise: Exercise) {
        self.id = exercise.id
        self.name = exercise.name
        self.category = exercise.category
    }

    init(_ kata: Kata) {
        self.id = kata.id
        self.name = kata.name
        self.category = kata.category
    }

    // Equatable to compare items
    static func == (lhs: AnyTrainingItem, rhs: AnyTrainingItem) -> Bool {
        return lhs.id == rhs.id
    }
}
