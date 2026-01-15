//
//  ViewModelProtocol.swift
import Foundation
import Combine

protocol ViewModelProtocol: ObservableObject {
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
}

// Helper extension to make it easier to conform
extension ViewModelProtocol {
    // Shared functionality can go here
}

