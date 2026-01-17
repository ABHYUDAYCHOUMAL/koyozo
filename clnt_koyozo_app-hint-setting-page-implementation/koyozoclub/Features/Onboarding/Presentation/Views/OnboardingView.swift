//  OnboardingView.swift
//  koyozoclub
//  Created by Rakshit Kanwal on 16/01/26.

// koyozoclub/Features/Onboarding/Presentation/Views/OnboardingView.swift

import SwiftUI
import Combine

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var cancellables = Set<AnyCancellable>()
    private let controllerManager = ControllerManager.shared
    
    init(viewModel: OnboardingViewModel = OnboardingViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Semi-transparent dark overlay to show background
                Color.black.opacity(0.85)
                    .ignoresSafeArea()
                
                VStack(spacing: 0)
                {
                    Spacer()
                    
                    // Main content card with white background
                    VStack(spacing: 0) {
                        // Onboarding content with TabView
                        TabView(selection: $viewModel.currentPageIndex) {
                            ForEach(viewModel.pages) { page in
                                OnboardingPageContentView(
                                    page: page,
                                    geometry: geometry
                                )
                                .tag(page.id)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: min(290, geometry.size.height * 0.75))
                        
                        // Page indicators
                        HStack(spacing: 3) {
                            ForEach(0..<viewModel.pages.count, id: \.self) { index in
                                Circle()
                                    .fill(index == viewModel.currentPageIndex ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.top, Spacing.sm)
                        .padding(.bottom, Spacing.sm)
                        
                        
                    }
                    .background(Color.clear)
                    .cornerRadius(24)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.lg)
                    .frame(maxWidth: min(600, geometry.size.width - 40))
                    
                    VStack {
                        // Buttons
                        HStack(spacing: Spacing.lg) {
                            if viewModel.isLastPage {
                                // Done button (full width on last page)
                                Button(action: {
                                    viewModel.completeOnboarding()
                                    coordinator.navigate(to: .gameLibrary)
                                }) {
                                    Text("Done")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: 80)
                                        .frame(height: 40)
                                        .background(AppTheme.Colors.accent)
                                        .cornerRadius(11)
                                }
                            } else {
                                // Skip button
                                Button(action: {
                                    viewModel.skipOnboarding()
                                    coordinator.navigate(to: .gameLibrary)
                                }) {
                                    Text("Skip")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: 80)
                                        .frame(height: 40)
                                        .background(.white)
                                        .cornerRadius(11)
                                }
                                
                                // Next button
                                Button(action: {
                                    viewModel.nextPage()
                                }) {
                                    Text("Next")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: 80)
                                        .frame(height: 40)
                                        .background(AppTheme.Colors.accent)
                                        .cornerRadius(11)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, Spacing.sm))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            setupControllerHandlers()
            controllerManager.startMonitoring()
        }
        .onDisappear {
            controllerManager.stopMonitoring()
            cancellables.removeAll()
        }
    }
    
    private func setupControllerHandlers() {
        // A Button - Next/Done
        controllerManager.onButtonAPressed
            .sink { [weak viewModel] in
                guard let viewModel = viewModel else { return }
                if viewModel.isLastPage {
                    viewModel.completeOnboarding()
                    coordinator.navigate(to: .gameLibrary)
                } else {
                    viewModel.nextPage()
                }
            }
            .store(in: &cancellables)
        
        // B Button - Skip (only if not last page)
        controllerManager.onButtonBPressed
            .sink { [weak viewModel] in
                guard let viewModel = viewModel else { return }
                if !viewModel.isLastPage {
                    viewModel.skipOnboarding()
                    coordinator.navigate(to: .gameLibrary)
                }
            }
            .store(in: &cancellables)
        
        // D-Pad Left - Previous page
        controllerManager.onDPadLeft
            .sink { [weak viewModel] in
                viewModel?.previousPage()
            }
            .store(in: &cancellables)
        
        // D-Pad Right - Next page
        controllerManager.onDPadRight
            .sink { [weak viewModel] in
                viewModel?.nextPage()
            }
            .store(in: &cancellables)
    }
}

// Individual page content view
struct OnboardingPageContentView: View {
    let page: OnboardingPage
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            // Controller image placeholder with white background
            ZStack
            {
                // White background for the image
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.clear)
                    .frame(
                        width: min(400, geometry.size.width * 0.6),
                        height: min(200, geometry.size.width * 0.45)
                    )
                
                // Controller illustration or system icon
                if page.id == 1 {
                    // Use actual controller image
                    Image("controller_diagram")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: min(350, geometry.size.width * 0.5))
                } else {
                    // Other pages use system icons
                    Image(systemName: getSystemImageName(for: page.id))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
//                        .frame(width: min(350, geometry.size.width * 0.3))
                        .frame(width: 100, height: 100)
                        .foregroundColor(AppTheme.Colors.accent)
                }
//                if page.id == 1 {
//                    // Page 2: Show actual controller image
//                    // TODO: Replace with actual controller image from assets
//                    Image(systemName: "gamecontroller.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: min(300, geometry.size.width * 0.5))
//                        .foregroundColor(.gray.opacity(0.3))
//                } else {
//                    // Other pages: Use system icons as placeholders
//                    Image(systemName: getSystemImageName(for: page.id))
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 100, height: 100)
//                        .foregroundColor(AppTheme.Colors.accent)
//                }
            }
            .padding(.bottom,-20)
            .padding(.top, 10)
            
            // Image dimensions text (like "328 x 168" in your reference)
//            if page.id == 1 {
//                Text("328 × 168")
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.blue)
//                    .padding(.bottom, Spacing.xs)
//            }
            
            // Controller hint text (like "Use Y for Pin/unpin")
//            if let hint = page.controllerHint {
//                Text(hint)
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.blue)
//                    .padding(.top, -10)
//            }
            
            // Title
            Text(page.title)
                .padding(.bottom, -3)
                .padding(.top, -3)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
//                .padding(.horizontal, Spacing.xl)
            
            // Description
            Text(page.description)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, -30)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private func getSystemImageName(for pageId: Int) -> String {
        switch pageId {
        case 0: return "sparkles"
        case 2: return "square.grid.3x3.fill"
        case 3: return "play.circle.fill"
        default: return "gamecontroller.fill"
        }
    }
}

#Preview {
    ZStack {
        // Mock background to simulate GameLibrary
        AppTheme.Colors.darkBlue
            .ignoresSafeArea()
        
        OnboardingView()
    }
    .environmentObject(AppCoordinator())
}
