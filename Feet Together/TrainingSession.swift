//
//  TrainingSession.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import Foundation

struct TrainingSession: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var timeBetweenTechniques: Int
    var isFeetTogetherEnabled: Bool
    var randomizeTechniques: Bool
    var sections: [TrainingSection]

    // Dictionaries for storing selected items
    var selectedExercises: [UUID: Bool] = [:]
    var selectedTechniques: [UUID: Bool] = [:]
    var selectedKatas: [UUID: Bool] = [:]
    
    static func == (lhs: TrainingSession, rhs: TrainingSession) -> Bool {
        return lhs.id == rhs.id
    }
}
