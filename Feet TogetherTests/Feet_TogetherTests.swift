//
//  Feet_TogetherTests.swift
//  Feet TogetherTests
//
//  Created by Aaron Addleman on 9/7/24.
//

import XCTest
import CoreData
@testable import Feet_Together

final class Feet_TogetherTests: XCTestCase {

    var coreDataHelper: CoreDataHelper!
    var persistentContainer: NSPersistentContainer!
    
    override func setUpWithError() throws {
        // Reset Core Data in-memory store
        let container = NSPersistentContainer(name: "FeetTogetherModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
        self.persistentContainer = container
    }

    override func tearDownWithError() throws {
        // Tear down the CoreDataHelper and persistent container after each test
        coreDataHelper = nil
        persistentContainer = nil
    }

    // Test creating a new technique in Core Data
    func testCreateTechnique() throws {
        let context = persistentContainer.viewContext
        let technique = coreDataHelper.createTechnique(context: context, name: "Test Technique", category: "Test Category")
        
        XCTAssertNotNil(technique.id)  // Check that the technique has an ID
        XCTAssertEqual(technique.name, "Test Technique")  // Verify the name
        XCTAssertEqual(technique.category, "Test Category")  // Verify the category
    }

    // Test saving and fetching selected techniques
    func testSaveAndFetchSelectedTechniques() throws {
        let context = persistentContainer.viewContext

        // Create and mark techniques as selected or not
        let technique1 = coreDataHelper.createTechnique(context: context, name: "Technique 1", category: "Category A")
        technique1.isSelected = true
        let technique2 = coreDataHelper.createTechnique(context: context, name: "Technique 2", category: "Category B")
        technique2.isSelected = false

        try context.save()  // Save techniques

        // Fetch selected techniques
        let selectedTechniques = coreDataHelper.fetchSelectedTechniques(context: context)

        XCTAssertEqual(selectedTechniques.count, 1)  // Only one technique should be selected
        XCTAssertEqual(selectedTechniques.first?.name, "Technique 1")  // Verify it's the correct technique
    }

    // Test saving and fetching selected exercises
    func testSaveAndFetchSelectedExercises() throws {
        let context = persistentContainer.viewContext

        // Create exercises
        let exercise1 = coreDataHelper.createExercise(context: context, name: "Exercise 1", reps: 10)
        exercise1.isSelected = true
        let exercise2 = coreDataHelper.createExercise(context: context, name: "Exercise 2", reps: 20)
        exercise2.isSelected = false

        try context.save()  // Save exercises

        // Fetch selected exercises
        let selectedExercises = coreDataHelper.fetchSelectedExercises(context: context)

        XCTAssertEqual(selectedExercises.count, 1)  // Only one exercise should be selected
        XCTAssertEqual(selectedExercises.first?.name, "Exercise 1")  // Verify it's the correct exercise
    }

    // Performance example: measuring Core Data save performance
    func testPerformanceExample() throws {
        measure {
            let context = persistentContainer.viewContext
            for i in 0..<100 {
                let _ = coreDataHelper.createTechnique(context: context, name: "Technique \(i)", category: "Category \(i)")
            }
            try? context.save()
        }
    }
}
