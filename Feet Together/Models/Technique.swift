//
//  Technique.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/7/24.
//

import Foundation

struct Technique: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var category: String = "General"

    // Initializer to convert Core Data object to Swift model
    init(from entity: TechniqueEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? "Unnamed Technique"
        self.category = entity.category ?? "General"
    }

    // Default initializer for manually created techniques
    init(name: String = "Unnamed Technique", category: String = "General") {
        self.name = name
        self.category = category
    }
}

let predefinedTechniques = [
    Technique(name: "Kimono Grab", category: "White"),
    Technique(name: "Eagles Beak A", category: "White"),
    Technique(name: "Eagles Beak B", category: "White"),
    Technique(name: "Striking Asp A", category: "White"),
    Technique(name: "Striking Asp B", category: "White"),
    Technique(name: "Crash of the Eagle A", category: "White"),
    Technique(name: "Crash of the Eagle B", category: "White"),
    Technique(name: "Crash of the Eagle C", category: "White"),
    Technique(name: "Crash of the Eagle D", category: "White"),
    Technique(name: "Full Nelson A", category: "White"),
    Technique(name: "Full Nelson B", category: "White"),
    Technique(name: "Arm Lock A", category: "White"),
    Technique(name: "Arm Lock B", category: "White"),
    Technique(name: "Arm Lock C", category: "White"),
    Technique(name: "Bear Hug Free A", category: "White"),
    Technique(name: "Bear Hug Free B", category: "White"),
    Technique(name: "Bear Hug Free C", category: "White"),
    Technique(name: "Inward Defense", category: "White"),
    Technique(name: "Outward Defense", category: "White"),
    Technique(name: "Crossing Talon", category: "White"),
    Technique(name: "Grasping Talon A", category: "White"),
    Technique(name: "Grasping Talon B", category: "White"),
    Technique(name: "Dancer A", category: "White"),
    Technique(name: "Dancer B", category: "White"),
    Technique(name: "Bear Hug Pinned A", category: "White"),
    Technique(name: "Bear Hug Pinned B", category: "White"),
    Technique(name: "Bear Hug Pinned C", category: "White"),
    Technique(name: "Cub A", category: "White"),
    Technique(name: "Cub B", category: "White"),
    Technique(name: "Headlock A", category: "White"),
    Technique(name: "Headlock B", category: "White"),
    Technique(name: "Headlock A and B", category: "White"),
    Technique(name: "Headlock C", category: "White"),
]
