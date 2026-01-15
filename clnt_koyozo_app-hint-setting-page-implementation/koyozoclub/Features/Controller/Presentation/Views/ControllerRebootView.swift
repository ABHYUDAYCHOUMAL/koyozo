//
//  ControllerRebootView.swift
import SwiftUI

struct ControllerRebootView: View {
    @StateObject private var viewModel: ControllerViewModel
    
    init(viewModel: ControllerViewModel = ControllerViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("Controller Reboot")
                .font(.title)
                .bold()
            
            Text("Rebooting your controller...")
                .foregroundColor(.gray)
            
            if viewModel.isRebooting {
                LoadingView()
            }
        }
        .padding()
        .onAppear {
            viewModel.rebootController()
        }
    }
}

#Preview {
    ControllerRebootView(viewModel: ControllerViewModel())
}

