//
//  GameLibraryUITests.swift
//  koyozoclubUITests
//
//  Created by Rakshit Kanwal on 06/11/25.
//

import XCTest

final class GameLibraryUITests: XCTestCase {
    
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
    
    func testGameLibraryScreen() {
        // UI Test for game library screen
    }
}

