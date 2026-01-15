//
//  CalibrateControllerUseCase.swift
import Foundation

protocol CalibrateControllerUseCaseProtocol {
    func execute() async throws
}

final class CalibrateControllerUseCase: CalibrateControllerUseCaseProtocol {
    private let controllerService: ControllerService
    
    init(controllerService: ControllerService? = nil) {
        self.controllerService = controllerService ?? ControllerService()
    }
    
    func execute() async throws {
        try await controllerService.calibrateController()
    }
}

