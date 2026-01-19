//
//  ControllerSettingsView.swift
import SwiftUI
import Combine

struct ControllerSettingsView: View {
    @StateObject private var viewModel: ControllerSettingsViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var cancellables = Set<AnyCancellable>()
    @State private var selectedSidebarIndex: Int = 0 // Start with "Controller testing" (index 0)
    private let controllerManager = ControllerManager.shared
    
    init(viewModel: ControllerSettingsViewModel = ControllerSettingsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                HStack(spacing: 0) {
                    // Left Sidebar
                    VStack(alignment: .leading, spacing: 0) {
                        // Header with back button
                        HStack {
                            Button(action: {
                                coordinator.pop()
                            }) {
                                HStack(spacing: Spacing.sm) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.text)
                                    
                                    Text("Controller settings")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.text)
                                }
                            }
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.md)
                            
                            Spacer()
                        }
                        .background(AppTheme.Colors.background)
                        
                        Divider()
                            .background(AppTheme.Colors.text.opacity(0.2))
                        
                        // Sidebar sections
                        ScrollView {
                            VStack(spacing: Spacing.xs) {
                                // Commented out section labels - can be enabled later
                                /*
                                Text("Mode")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.5))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, Spacing.md)
                                    .padding(.top, Spacing.md)
                                    .padding(.bottom, Spacing.xs)
                                
                                Text("Connection type")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.5))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, Spacing.md)
                                    .padding(.bottom, Spacing.sm)
                                */
                                
                                // Clickable sections
                                ForEach(Array(ControllerSettingSection.allCases.enumerated()), id: \.element.id) { index, section in
                                    SidebarItemView(
                                        title: section.title,
                                        isSelected: selectedSidebarIndex == index,
                                        onTap: {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                selectedSidebarIndex = index
                                                viewModel.selectedSection = section
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .frame(width: geometry.size.width * 0.3)
                    .background(AppTheme.Colors.background)
                    
                    Divider()
                        .background(AppTheme.Colors.text.opacity(0.2))
                    
                    // Right Content Area
                    ZStack {
                        AppTheme.Colors.background
                        
                        // Content based on selected section
                        Group {
                            switch viewModel.selectedSection {
                            // Commented out sections - can be enabled later
                            /*
                            case .controllerTesting:
                                ControllerTestingContentView(
                                    steps: viewModel.controllerTestingSteps
                                )
                            */
                            case .knowYourController:
                                KnowYourControllerContentView(
                                    modeChangeSteps: viewModel.modeChangeSteps,
                                    modesTable: viewModel.modesTable,
                                    bluetoothSteps: viewModel.bluetoothConnectionSteps,
                                    bluetoothSubSteps: viewModel.bluetoothConnectionSubSteps,
                                    bluetoothFinalSteps: viewModel.bluetoothConnectionFinalSteps,
                                    connectionStates: viewModel.connectionStates
                                )
                            case .troubleShooting:
                                TroubleshootingContentView(
                                    faqItems: viewModel.troubleshootingFAQs,
                                    expandedIds: viewModel.expandedFAQIds,
                                    onToggle: { id in
                                        viewModel.toggleFAQ(id)
                                    }
                                )
                            /*
                            case .screenMapping:
                                ScreenMappingContentView()
                            */
                            case .generalFAQ:
                                GeneralFAQContentView(
                                    faqItems: viewModel.generalFAQs,
                                    expandedIds: viewModel.expandedFAQIds,
                                    onToggle: { id in
                                        viewModel.toggleFAQ(id)
                                    },
                                    isLoading: viewModel.isLoading,
                                    errorMessage: viewModel.errorMessage
                                )
                            /*
                            default:
                                // Placeholder for Mode and Connection type sections
                                VStack {
                                    Text("Coming Soon")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            */
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupControllerHandlers()
            controllerManager.startMonitoring()
            viewModel.fetchGeneralFAQs()  // Fetch General FAQs from API
        }
        .onDisappear {
            controllerManager.stopMonitoring()
            cancellables.removeAll()
        }
    }
    
    private func setupControllerHandlers() {
        // B Button - Back
        controllerManager.onButtonBPressed
            .sink {
                coordinator.pop()
            }
            .store(in: &cancellables)
        
        // D-Pad Up - Previous section
        controllerManager.onDPadUp
            .sink {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if selectedSidebarIndex > 0 {
                        selectedSidebarIndex -= 1
                        viewModel.selectedSection = ControllerSettingSection.allCases[selectedSidebarIndex]
                    }
                }
            }
            .store(in: &cancellables)
        
        // D-Pad Down - Next section
        controllerManager.onDPadDown
            .sink {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if selectedSidebarIndex < ControllerSettingSection.allCases.count - 1 {
                        selectedSidebarIndex += 1
                        viewModel.selectedSection = ControllerSettingSection.allCases[selectedSidebarIndex]
                    }
                }
            }
            .store(in: &cancellables)
    }
}

// Sidebar Item Component
struct SidebarItemView: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? AppTheme.Colors.text : AppTheme.Colors.text.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, Spacing.sm)
                .padding(.horizontal, Spacing.md)
                .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, Spacing.sm)
    }
}

#Preview {
    NavigationStack {
        ControllerSettingsView()
    }
    .environmentObject(AppCoordinator())
}
