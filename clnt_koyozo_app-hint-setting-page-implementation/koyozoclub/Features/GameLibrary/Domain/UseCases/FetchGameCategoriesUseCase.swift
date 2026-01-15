//
//  FetchGameCategoriesUseCase.swift
import Foundation

protocol FetchGameCategoriesUseCaseProtocol {
    func execute() async throws -> [GameCategory]
}

final class FetchGameCategoriesUseCase: FetchGameCategoriesUseCaseProtocol {
    private let gameRepository: GameRepository
    
    init(gameRepository: GameRepository? = nil) {
        self.gameRepository = gameRepository ?? GameRepository()
    }
    
    func execute() async throws -> [GameCategory] {
        return try await gameRepository.fetchCategories()
    }
}

