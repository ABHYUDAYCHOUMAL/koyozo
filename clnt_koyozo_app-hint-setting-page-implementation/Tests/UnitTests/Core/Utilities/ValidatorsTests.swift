//
//  ValidatorsTests.swift
//  koyozoclubTests
//
//  Created by Rakshit Kanwal on 06/11/25.
//

import XCTest
@testable import koyozoclub

final class ValidatorsTests: XCTestCase {
    
    func testIsValidEmail() {
        XCTAssertTrue(Validators.isValidEmail("test@example.com"))
        XCTAssertFalse(Validators.isValidEmail("invalid-email"))
        XCTAssertFalse(Validators.isValidEmail(""))
    }
    
    func testIsValidPassword() {
        XCTAssertTrue(Validators.isValidPassword("password123"))
        XCTAssertFalse(Validators.isValidPassword("short"))
        XCTAssertFalse(Validators.isValidPassword(""))
    }
}

