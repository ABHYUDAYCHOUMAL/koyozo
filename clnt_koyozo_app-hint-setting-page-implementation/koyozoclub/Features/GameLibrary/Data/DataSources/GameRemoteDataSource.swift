//
//  GameRemoteDataSource.swift
import Foundation

// MARK: - Protocol

protocol GameRemoteDataSourceProtocol {
    /// Fetch games with pagination, sorting, and optional search
    func fetchGames(
        pageNumber: Int,
        pageSize: Int,
        sortBy: String,
        sortOrder: String,
        search: String?
    ) async throws -> iOSGamesDataDTO
    
    /// Fetch a single game by ID
    func fetchGame(by id: String) async throws -> Game
    
    /// Fetch categories (not currently supported by iOS Games API)
    func fetchCategories() async throws -> [GameCategory]
}

// MARK: - iOS Games API Endpoints

/// Endpoint for fetching paginated games list
/// GET /ios-games?pageSize=20&pageNumber=0&sortBy=rating&sortOrder=desc&search=optional
struct iOSGamesEndpoint: APIEndpoint {
    let path: String = "/ios-games"
    let method: HTTPMethod = .get
    let headers: [String: String]? = nil
    let body: Data? = nil
    let queryParameters: [String: String]?
    
    init(
        pageNumber: Int = 0,
        pageSize: Int = Constants.API.defaultPageSize,
        sortBy: String = Constants.API.defaultSortBy,
        sortOrder: String = Constants.API.defaultSortOrder,
        search: String? = nil
    ) {
        var params: [String: String] = [
            "pageNumber": String(pageNumber),
            "pageSize": String(pageSize),
            "sortBy": sortBy,
            "sortOrder": sortOrder
        ]
        
        if let search = search, !search.isEmpty {
            params["search"] = search
        }
        
        self.queryParameters = params
    }
}

/// Endpoint for fetching a single game by ID
/// GET /ios-game?gameId=610391947
struct iOSGameByIdEndpoint: APIEndpoint {
    let path: String = "/ios-game"
    let method: HTTPMethod = .get
    let headers: [String: String]? = nil
    let body: Data? = nil
    let queryParameters: [String: String]?
    
    init(gameId: String) {
        self.queryParameters = ["gameId": gameId]
    }
}

// MARK: - Implementation

final class GameRemoteDataSource: GameRemoteDataSourceProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient? = nil) {
        self.apiClient = apiClient ?? AppDependencies.shared.apiClient
    }
    
    /// Fetch games with pagination, sorting, and optional search
    /// - Parameters:
    ///   - pageNumber: Page number (0-indexed)
    ///   - pageSize: Number of games per page
    ///   - sortBy: Field to sort by (title, rating, createdAt, updatedAt, app_store_id)
    ///   - sortOrder: Sort order (asc or desc)
    ///   - search: Optional search term to filter games
    /// - Returns: iOSGamesDataDTO containing games, pagination, and sort info
    func fetchGames(
        pageNumber: Int,
        pageSize: Int,
        sortBy: String,
        sortOrder: String,
        search: String?
    ) async throws -> iOSGamesDataDTO {
        let endpoint = iOSGamesEndpoint(
            pageNumber: pageNumber,
            pageSize: pageSize,
            sortBy: sortBy,
            sortOrder: sortOrder,
            search: search
        )
        
        do {
            let data = try await apiClient.request(endpoint)
            let decoder = JSONDecoder()
            let response = try decoder.decode(iOSGamesResponseDTO.self, from: data)
            
            guard !response.hasError else {
                let errorMessage = response.normalizedErrors.first ?? "Unknown error"
                throw AppError.networkError(errorMessage)
            }
            
            guard let gamesData = response.data else {
                throw AppError.invalidData
            }
            
            return gamesData
        } catch let error as AppError {
            throw error
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    /// Fetch a single game by its ID
    /// - Parameter id: The game ID (App Store ID)
    /// - Returns: Game domain model
    func fetchGame(by id: String) async throws -> Game {
        let endpoint = iOSGameByIdEndpoint(gameId: id)
        
        do {
            let data = try await apiClient.request(endpoint)
            let decoder = JSONDecoder()
            let response = try decoder.decode(iOSGameResponseDTO.self, from: data)
            
            guard !response.hasError else {
                let errorMessage = response.normalizedErrors.first ?? "Unknown error"
                throw AppError.networkError(errorMessage)
            }
            
            guard let gameDTO = response.data else {
                throw AppError.invalidData
            }
            
            return GameMapper.toDomain(from: gameDTO)
        } catch let error as AppError {
            throw error
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    /// Fetch categories - not currently supported by iOS Games API
    /// - Returns: Empty array (categories not implemented in current API)
    func fetchCategories() async throws -> [GameCategory] {
        // iOS Games API does not currently support categories endpoint
        // Return empty array for now
        return []
    }
}

