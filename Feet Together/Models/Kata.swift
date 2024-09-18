//
//  Kata.swift
//  Feet Together
//
//  Created by Aaron Addleman on 9/16/24.
//

import Foundation

struct Kata: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var category: String = "General"

    init(from entity: KataEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? "Unnamed Kata"
        self.category = entity.category ?? "General"
    }
}
