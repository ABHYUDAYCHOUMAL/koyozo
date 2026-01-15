//
//  ControllerConnectionView.swift
import SwiftUI

struct ControllerConnectionView: View {
    @StateObject private var viewModel: ControllerViewModel
    
    init(viewModel: ControllerViewModel = ControllerViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "gamecontroller.fill")
                .imageScale(.large)
                .foregroundColor(viewModel.isConnected ? .green : .gray)
            
            Text(viewModel.isConnected ? "Controller Connected" : "Connect Controller")
                .font(.headline)
            
            if !viewModel.isConnected {
                PrimaryButton(title: "Search for Controller") {
                    viewModel.searchForController()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ControllerConnectionView(viewModel: ControllerViewModel())
}

