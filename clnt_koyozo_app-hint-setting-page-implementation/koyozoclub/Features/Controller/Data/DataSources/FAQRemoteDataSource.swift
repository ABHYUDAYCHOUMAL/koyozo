//
//  FAQRemoteDataSource.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 18/01/26.
//

//  FAQRemoteDataSource.swift
import Foundation

protocol FAQRemoteDataSourceProtocol {
    func fetchFAQs() async throws -> [FAQItemDTO]
}

/// Endpoint for fetching FAQs
struct FAQsEndpoint: APIEndpoint {
    let path: String = "/faqs"
    let method: HTTPMethod = .get
    let headers: [String: String]? = nil
    let body: Data? = nil
    let queryParameters: [String: String]? = nil
}

final class FAQRemoteDataSource: FAQRemoteDataSourceProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient? = nil) {
        self.apiClient = apiClient ?? AppDependencies.shared.apiClient
    }
    
    func fetchFAQs() async throws -> [FAQItemDTO] {
        let endpoint = FAQsEndpoint()
        
        do {
            let data = try await apiClient.request(endpoint)
            let decoder = JSONDecoder()
            let response = try decoder.decode(FAQResponseDTO.self, from: data)
            
            guard !response.hasError else {
                let errorMessage = response.error?.first ?? "Unknown error"
                throw AppError.networkError(errorMessage)
            }
            
            guard let faqData = response.data else {
                throw AppError.invalidData
            }
            
            return faqData.faqs
        } catch let error as DecodingError {
            // Provide more detailed error information for debugging
            let errorDescription: String
            switch error {
            case .dataCorrupted(let context):
                errorDescription = "Data corrupted: \(context.debugDescription)"
            case .keyNotFound(let key, let context):
                errorDescription = "Key '\(key.stringValue)' not found: \(context.debugDescription)"
            case .typeMismatch(let type, let context):
                errorDescription = "Type mismatch for type \(type): \(context.debugDescription)"
            case .valueNotFound(let type, let context):
                errorDescription = "Value not found for type \(type): \(context.debugDescription)"
            @unknown default:
                errorDescription = "Decoding error: \(error.localizedDescription)"
            }
            throw AppError.networkError("Failed to decode FAQ response: \(errorDescription)")
        } catch let error as AppError {
            throw error
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}
