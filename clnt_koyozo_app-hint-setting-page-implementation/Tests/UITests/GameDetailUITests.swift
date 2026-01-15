//
//  GameDetailUITests.swift
//  koyozoclubUITests
//
//  Created by Rakshit Kanwal on 06/11/25.
//

import XCTest

final class GameDetailUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    func testGameDetailScreen() {
        // UI Test for game detail screen
    }
}

