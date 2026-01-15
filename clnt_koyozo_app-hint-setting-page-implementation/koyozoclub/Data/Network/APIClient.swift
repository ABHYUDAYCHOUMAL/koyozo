//
//  APIClient.swift
import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func request(_ endpoint: APIEndpoint) async throws -> Data
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let baseURL: String
    
    init(session: URLSession = .shared, baseURL: String = "") {
        self.session = session
        self.baseURL = baseURL
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let data = try await request(endpoint)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
    
    func request(_ endpoint: APIEndpoint) async throws -> Data {
        let request = try RequestBuilder.build(endpoint: endpoint, baseURL: baseURL)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            try ResponseHandler.handle(httpResponse, data: data)
            return data
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}

