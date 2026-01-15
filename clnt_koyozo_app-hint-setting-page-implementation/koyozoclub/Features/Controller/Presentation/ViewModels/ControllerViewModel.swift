//
//  ControllerViewModel.swift
import Foundation
import SwiftUI
import Combine

class ControllerViewModel: ViewModelProtocol {
    var isLoading: Bool = false
    var errorMessage: String?
    
    var isConnected: Bool = false
    var isRebooting: Bool = false
    
    private let detectControllerUseCase: DetectControllerUseCase
    private let calibrateControllerUseCase: CalibrateControllerUseCase
    private let rebootControllerUseCase: RebootControllerUseCase
    
    init(
        detectControllerUseCase: DetectControllerUseCase? = nil,
        calibrateControllerUseCase: CalibrateControllerUseCase? = nil,
        rebootControllerUseCase: RebootControllerUseCase? = nil
    ) {
        self.detectControllerUseCase = detectControllerUseCase ?? DetectControllerUseCase()
        self.calibrateControllerUseCase = calibrateControllerUseCase ?? CalibrateControllerUseCase()
        self.rebootControllerUseCase = rebootControllerUseCase ?? RebootControllerUseCase()
    }
    
    func searchForController() {
        Task {
            isLoading = true
            do {
                isConnected = try await detectControllerUseCase.execute()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func startCalibration() {
        Task {
            isLoading = true
            do {
                try await calibrateControllerUseCase.execute()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func rebootController() {
        Task {
            isRebooting = true
            do {
                try await rebootControllerUseCase.execute()
            } catch {
                errorMessage = error.localizedDescription
            }
            isRebooting = false
        }
    }
}

