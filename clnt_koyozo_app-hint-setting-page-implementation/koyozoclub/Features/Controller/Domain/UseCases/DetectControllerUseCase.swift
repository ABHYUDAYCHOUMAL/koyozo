//
//  DetectControllerUseCase.swift
import Foundation

protocol DetectControllerUseCaseProtocol {
    func execute() async throws -> Bool
}

final class DetectControllerUseCase: DetectControllerUseCaseProtocol {
    private let controllerService: ControllerService
    
    init(controllerService: ControllerService? = nil) {
        self.controllerService = controllerService ?? ControllerService()
    }
    
    func execute() async throws -> Bool {
        return try await controllerService.detectController()
    }
}

