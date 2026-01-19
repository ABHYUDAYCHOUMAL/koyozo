//
//  FetchFAQsUseCase.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 18/01/26.
//

//  FetchFAQsUseCase.swift
import Foundation

protocol FetchFAQsUseCaseProtocol {
    func execute() async throws -> [FAQItem]
}

final class FetchFAQsUseCase: FetchFAQsUseCaseProtocol {
    private let faqRepository: FAQRepository
    
    init(faqRepository: FAQRepository? = nil) {
        self.faqRepository = faqRepository ?? FAQRepository()
    }
    
    func execute() async throws -> [FAQItem] {
        return try await faqRepository.fetchFAQs()
    }
}
