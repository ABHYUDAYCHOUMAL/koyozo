//
//  ControllerSetupView.swift
import SwiftUI

struct ControllerSetupView: View {
    @StateObject private var viewModel: GameDetailViewModel
    
    init(viewModel: GameDetailViewModel? = nil, gameId: String = "1") {
        let vm = viewModel ?? GameDetailViewModel(gameId: gameId)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("Controller Setup")
                .font(.headline)
            
            if viewModel.isControllerConnected {
                Text("Controller connected")
                    .foregroundColor(.green)
            } else {
                Text("Connect your controller to continue")
                    .foregroundColor(.orange)
            }
        }
        .padding()
    }
}

#Preview {
    ControllerSetupView(gameId: "1")
}

