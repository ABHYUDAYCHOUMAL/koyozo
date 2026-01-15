//
//  RebootControllerUseCase.swift
import Foundation

protocol RebootControllerUseCaseProtocol {
    func execute() async throws
}

final class RebootControllerUseCase: RebootControllerUseCaseProtocol {
    private let controllerService: ControllerService
    
    init(controllerService: ControllerService? = nil) {
        self.controllerService = controllerService ?? ControllerService()
    }
    
    func execute() async throws {
        try await controllerService.rebootController()
    }
}

