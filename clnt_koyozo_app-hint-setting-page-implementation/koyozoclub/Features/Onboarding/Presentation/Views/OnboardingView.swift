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
                                    geometry: geometry,
                                    isCurrentPage: viewModel.currentPageIndex == page.id
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
    let isCurrentPage: Bool
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            // Video or image container
            ZStack {
                // Container background
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.clear)
                    .frame(
                        width: min(400, geometry.size.width * 0.6),
                        height: min(200, geometry.size.width * 0.45)
                    )
                
                // Display video if available
                if let videoName = page.videoName {
                    LoopingVideoPlayerView(
                        videoName: videoName,
                        isPlaying: isCurrentPage
                    )
                    .frame(
                        width: min(400, geometry.size.width * 0.6),
                        height: min(200, geometry.size.width * 0.45)
                    )
                    .cornerRadius(16)
                    .clipped()
                } else if page.id == 0 {
                    // Welcome page - use controller image
                    Image("controller_diagram")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: min(350, geometry.size.width * 0.5))
                } else if page.id == 4 {
                    // X button placeholder - use icon
                    Image(systemName: "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(AppTheme.Colors.accent)
                } else if page.id == 8 {
                    // Final page - use system icon
                    Image(systemName: "play.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(AppTheme.Colors.accent)
                } else if let imageName = page.imageName {
                    // Fallback to image if provided
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: min(350, geometry.size.width * 0.5))
                } else {
                    // Default icon
                    Image(systemName: "gamecontroller.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(AppTheme.Colors.accent)
                }
            }
            .padding(.bottom, -20)
            .padding(.top, 10)
            
            // Title only
            Text(page.title)
                .padding(.bottom, -3)
                .padding(.top, -3)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
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
