//
//  FAQRepository.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 18/01/26.
//

//  FAQRepository.swift
import Foundation

protocol FAQRepositoryProtocol {
    func fetchFAQs() async throws -> [FAQItem]
}

final class FAQRepository: FAQRepositoryProtocol {
    private let remoteDataSource: FAQRemoteDataSource
    
    init(remoteDataSource: FAQRemoteDataSource? = nil) {
        self.remoteDataSource = remoteDataSource ?? FAQRemoteDataSource()
    }
    
    func fetchFAQs() async throws -> [FAQItem] {
        let dtos = try await remoteDataSource.fetchFAQs()
        return FAQMapper.toDomain(from: dtos)
    }
}
