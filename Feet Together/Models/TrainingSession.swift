//
//  TrainingSession.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import Foundation

struct TrainingSession: Identifiable, Hashable, Equatable {
    var id: UUID
    var name: String
    var techniques: [Technique]
    var exercises: [Exercise]
    var katas: [Kata]
    var timeBetweenTechniques: Int
    var isFeetTogetherEnabled: Bool
    var randomizeTechniques: Bool

    // Manual initializer
    init(
        id: UUID = UUID(),
        name: String,
        techniques: [Technique],
        exercises: [Exercise],
        katas: [Kata],
        timeBetweenTechniques: Int,
        isFeetTogetherEnabled: Bool,
        randomizeTechniques: Bool
    ) {
        self.id = id
        self.name = name
        self.techniques = techniques
        self.exercises = exercises
        self.katas = katas
        self.timeBetweenTechniques = timeBetweenTechniques
        self.isFeetTogetherEnabled = isFeetTogetherEnabled
        self.randomizeTechniques = randomizeTechniques
    }

    // Initializer for creating from Core Data entity
    init(from entity: TrainingSessionEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? "Unnamed Session"
        self.techniques = (entity.selectedTechniques?.allObjects as? [TechniqueEntity])?.map { Technique(from: $0) } ?? []
        self.exercises = (entity.selectedExercises?.allObjects as? [ExerciseEntity])?.map { Exercise(from: $0) } ?? []
        self.katas = (entity.selectedKatas?.allObjects as? [KataEntity])?.map { Kata(from: $0) } ?? []
        self.timeBetweenTechniques = Int(entity.timeBetweenTechniques)
        self.isFeetTogetherEnabled = entity.isFeetTogetherEnabled
        self.randomizeTechniques = entity.randomizeTechniques
    }

    // Implementing Hashable by combining relevant properties
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(techniques)
        hasher.combine(exercises)
        hasher.combine(katas)
        hasher.combine(timeBetweenTechniques)
        hasher.combine(isFeetTogetherEnabled)
        hasher.combine(randomizeTechniques)
    }
}

