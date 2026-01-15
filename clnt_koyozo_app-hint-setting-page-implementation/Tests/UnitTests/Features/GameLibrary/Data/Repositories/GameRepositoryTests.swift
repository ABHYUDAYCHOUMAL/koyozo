//
//  GameRepositoryTests.swift
//  koyozoclubTests
//
//  Created by Rakshit Kanwal on 06/11/25.
//

import XCTest
@testable import koyozoclub

final class GameRepositoryTests: XCTestCase {
    
    var gameRepository: GameRepository!
    var mockRemoteDataSource: MockGameRemoteDataSource!
    var mockLocalDataSource: MockGameLocalDataSource!
    
    override func setUp() {
        super.setUp()
        mockRemoteDataSource = MockGameRemoteDataSource()
        mockLocalDataSource = MockGameLocalDataSource()
        gameRepository = GameRepository(
            remoteDataSource: mockRemoteDataSource,
            localDataSource: mockLocalDataSource
        )
    }
    
    override func tearDown() {
        gameRepository = nil
        mockRemoteDataSource = nil
        mockLocalDataSource = nil
        super.tearDown()
    }
    
    func testFetchGames() async throws {
        // Implement test
    }
}

// MARK: - Mock Data Sources
class MockGameRemoteDataSource: GameRemoteDataSourceProtocol {
    func fetchGames() async throws -> [Game] {
        return []
    }
    
    func fetchCategories() async throws -> [GameCategory] {
        return []
    }
    
    func fetchGame(by id: String) async throws -> Game {
        throw AppError.unknown
    }
}

class MockGameLocalDataSource: GameLocalDataSourceProtocol {
    func fetchGames() async throws -> [Game] {
        return []
    }
    
    func fetchRecentGames() async throws -> [Game] {
        return []
    }
    
    func fetchGame(by id: String) async throws -> Game? {
        return nil
    }
    
    func saveGames(_ games: [Game]) async throws {
        // Mock implementation
    }
    
    func saveGame(_ game: Game) async throws {
        // Mock implementation
    }
    
    func markGameAsRecent(_ game: Game) async throws {
        // Mock implementation
    }
}

