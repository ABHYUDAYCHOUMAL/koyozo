//
//  SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    
    init(viewModel: SettingsViewModel = SettingsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("General") {
                    Toggle("Enable Notifications", isOn: $viewModel.preferences.notificationsEnabled)
                    Toggle("Auto-launch Games", isOn: $viewModel.preferences.autoLaunchEnabled)
                }
                
                Section("Controller") {
                    Toggle("Vibration", isOn: $viewModel.preferences.vibrationEnabled)
                    Stepper("Sensitivity: \(Int(viewModel.preferences.sensitivity))", 
                           value: $viewModel.preferences.sensitivity, 
                           in: 0...100)
                }
            }
            .navigationTitle("Settings")
            .onChange(of: viewModel.preferences.notificationsEnabled) { _, _ in
                viewModel.savePreferences()
            }
            .onChange(of: viewModel.preferences.autoLaunchEnabled) { _, _ in
                viewModel.savePreferences()
            }
            .onChange(of: viewModel.preferences.vibrationEnabled) { _, _ in
                viewModel.savePreferences()
            }
            .onChange(of: viewModel.preferences.sensitivity) { _, _ in
                viewModel.savePreferences()
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}

