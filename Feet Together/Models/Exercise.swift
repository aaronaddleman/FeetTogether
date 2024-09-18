//
//  Exercise.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/16/24.
//

import Foundation

struct Exercise: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var category: String = "General"

    init(from entity: ExerciseEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? "Unnamed Exercise"
        self.category = entity.category ?? "General"
    }
}
