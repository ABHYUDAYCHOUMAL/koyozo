//
//  ControllerCalibrationView.swift
import SwiftUI

struct ControllerCalibrationView: View {
    @StateObject private var viewModel: ControllerViewModel
    
    init(viewModel: ControllerViewModel = ControllerViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("Controller Calibration")
                .font(.title)
                .bold()
            
            Text("Follow the on-screen instructions to calibrate your controller")
                .multilineTextAlignment(.center)
                .padding()
            
            PrimaryButton(title: "Start Calibration") {
                viewModel.startCalibration()
            }
        }
        .padding()
    }
}

#Preview {
    ControllerCalibrationView(viewModel: ControllerViewModel())
}

