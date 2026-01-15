//
//  SplashView.swift
import SwiftUI

struct SplashView: View {
    @StateObject private var viewModel: SplashViewModel
    
    init(viewModel: SplashViewModel = SplashViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            Image(systemName: "gamecontroller.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Koyozo")
                .font(.largeTitle)
                .bold()
        }
        .padding()
        .onAppear {
            viewModel.checkAuthenticationStatus()
        }
    }
}

#Preview {
    SplashView(viewModel: SplashViewModel())
}

