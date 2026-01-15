//
//  AuthenticationUITests.swift
//  koyozoclubUITests
//
//  Created by Rakshit Kanwal on 06/11/25.
//

import XCTest

final class AuthenticationUITests: XCTestCase {
    
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
    
    func testLoginScreen() {
        // UI Test for login screen
        let emailTextField = app.textFields["Email"]
        XCTAssertTrue(emailTextField.exists)
        
        let passwordTextField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordTextField.exists)
        
        let loginButton = app.buttons["Login"]
        XCTAssertTrue(loginButton.exists)
    }
}

