//
//  LoginUseCaseTests.swift
//  koyozoclubTests
//
//  Created by Rakshit Kanwal on 06/11/25.
//

import XCTest
@testable import koyozoclub

final class LoginUseCaseTests: XCTestCase {
    
    var loginUseCase: LoginUseCase!
    var mockAuthRepository: MockAuthRepository!
    
    override func setUp() {
        super.setUp()
        mockAuthRepository = MockAuthRepository()
        loginUseCase = LoginUseCase(authRepository: mockAuthRepository)
    }
    
    override func tearDown() {
        loginUseCase = nil
        mockAuthRepository = nil
        super.tearDown()
    }
    
    func testLoginSuccess() async throws {
        // Given
        let expectedToken = AuthToken(accessToken: "token", refreshToken: nil, expiresIn: 3600)
        mockAuthRepository.loginResult = .success(expectedToken)
        
        // When
        let token = try await loginUseCase.execute(email: "test@example.com", password: "password")
        
        // Then
        XCTAssertEqual(token.accessToken, expectedToken.accessToken)
    }
    
    func testLoginFailure() async {
        // Given
        mockAuthRepository.loginResult = .failure(AppError.authenticationFailed)
        
        // When/Then
        do {
            _ = try await loginUseCase.execute(email: "test@example.com", password: "wrong")
            XCTFail("Should throw error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}

// MARK: - Mock Repository
class MockAuthRepository: AuthRepositoryProtocol {
    var loginResult: Result<AuthToken, Error>?
    
    func login(email: String, password: String) async throws -> AuthToken {
        guard let result = loginResult else {
            throw AppError.unknown
        }
        return try result.get()
    }
    
    func signup(name: String, email: String, password: String) async throws -> AuthToken {
        throw AppError.unknown
    }
    
    func signInWithGoogle() async throws -> AuthToken {
        throw AppError.unknown
    }
    
    func logout() async throws {
        throw AppError.unknown
    }
}

