//
//  KeychainManagerTests.swift
//  koyozoclubTests
//
//  Created by Rakshit Kanwal on 06/11/25.
//

import XCTest
@testable import koyozoclub

final class KeychainManagerTests: XCTestCase {
    
    var keychainManager: KeychainManager!
    
    override func setUp() {
        super.setUp()
        keychainManager = KeychainManager()
    }
    
    override func tearDown() {
        // Clean up test data
        try? keychainManager.delete(forKey: "test_key")
        keychainManager = nil
        super.tearDown()
    }
    
    func testSaveAndFetch() throws {
        // Given
        let testData = "test_value".data(using: .utf8)!
        
        // When
        try keychainManager.save(testData, forKey: "test_key")
        let fetchedData = try keychainManager.fetch(forKey: "test_key")
        
        // Then
        XCTAssertEqual(fetchedData, testData)
    }
    
    func testDelete() throws {
        // Given
        let testData = "test_value".data(using: .utf8)!
        try keychainManager.save(testData, forKey: "test_key")
        
        // When
        try keychainManager.delete(forKey: "test_key")
        let fetchedData = try keychainManager.fetch(forKey: "test_key")
        
        // Then
        XCTAssertNil(fetchedData)
    }
}

