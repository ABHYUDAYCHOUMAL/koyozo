//
//  APIClientTests.swift
//  koyozoclubTests
//
//  Created by Rakshit Kanwal on 06/11/25.
//

import XCTest
@testable import koyozoclub

final class APIClientTests: XCTestCase {
    
    var apiClient: APIClient!
    
    override func setUp() {
        super.setUp()
        apiClient = APIClient()
    }
    
    override func tearDown() {
        apiClient = nil
        super.tearDown()
    }
    
    func testRequestSuccess() async {
        // Implement test with mock URLSession
    }
    
    func testRequestFailure() async {
        // Implement test for error handling
    }
}

