//
//  UserInformationView.swift
import SwiftUI

struct UserInformationView: View {
    let email: String
    let password: String
    @StateObject private var viewModel: UserInformationViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    init(email: String, password: String, viewModel: UserInformationViewModel? = nil) {
        self.email = email
        self.password = password
        _viewModel = StateObject(wrappedValue: viewModel ?? UserInformationViewModel())
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark blue background
                AppTheme.Colors.darkBlue
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Navigation Bar
                    customNavigationBar(topInset: geometry.safeAreaInsets.top)
                    
                    // Centered vertical layout - no scrolling
                    VStack(spacing: Spacing.sm) {
                        // Title
                        Text("Tell us about you")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.Colors.white)
                            .padding(.top, Spacing.xs)
                        
                        // Full Name Field
                        LabeledTextField(
                            label: "Full name",
                            placeholder: "Enter full name",
                            text: $viewModel.fullName
                        )
                        .frame(width: min(400, geometry.size.width * 0.7))
                        
                        // Birthdate and Gender in one row
                        HStack(alignment: .top, spacing: Spacing.md) {
                            // Gender Field
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Gender")
                                    .font(.body)
                                    .foregroundColor(AppTheme.Colors.white)
                                
                                Menu {
                                    ForEach(viewModel.genderOptions, id: \.self) { option in
                                        Button(action: {
                                            viewModel.selectedGender = option
                                        }) {
                                            Text(option)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(viewModel.selectedGender ?? "Select")
                                            .foregroundColor(
                                                viewModel.selectedGender == nil ?
                                                Color.gray :
                                                    AppTheme.Colors.darkBlue
                                            )
                                            .font(.body)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(AppTheme.Colors.darkBlue)
                                            .font(.caption)
                                    }
                                    .padding(.vertical, Spacing.md)
                                    .padding(.horizontal, Spacing.sm + Spacing.xs)
                                    .background(AppTheme.Colors.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppTheme.Colors.darkBlue, lineWidth: 1)
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .layoutPriority(1) // let gender take a bit more width
                            
                            // Birthdate Field
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Birthdate")
                                    .font(.body)
                                    .foregroundColor(AppTheme.Colors.white)
                                
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { viewModel.birthdate ?? Date() },
                                        set: { viewModel.birthdate = $0 }
                                    ),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .padding(.vertical, Spacing.md)
                                .padding(.horizontal, Spacing.sm + Spacing.xs)
                                .frame(minHeight: 48) // match height with gender control
                                .background(AppTheme.Colors.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppTheme.Colors.darkBlue, lineWidth: 1)
                                )
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(width: min(400, geometry.size.width * 0.7))
                        
                        // Error Message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(width: min(400, geometry.size.width * 0.7))
                        }
                        
                        // Continue Button
                        PrimaryButton(title: "Continue") {
                            viewModel.submitUserInfo()
                        }
                        .frame(width: min(400, geometry.size.width * 0.7))
                        .padding(.top, Spacing.xs)
                        .disabled(viewModel.isLoading)
                        
                        // Terms and Privacy Links
                        HStack(spacing: Spacing.xs) {
                            Button(action: {
                                // Navigate to Terms of use
                            }) {
                                Text("Terms of use")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.Colors.white.opacity(0.7))
                            }
                            
                            Text("|")
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.white.opacity(0.7))
                            
                            Button(action: {
                                // Navigate to Privacy policy
                            }) {
                                Text("Privacy policy")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.Colors.white.opacity(0.7))
                            }
                        }
                        .padding(.top, Spacing.md)
                        .padding(.bottom, Spacing.md)
                        
                        // Loading Indicator
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden()
            .onAppear {
                // Store email in lowercase for consistency
                viewModel.email = email.lowercased()
                viewModel.password = password
                viewModel.onNavigate = { route in
                    // Clear navigation path when navigating to gameLibrary (after successful registration)
                    // This prevents showing a back button to login page
                    if case .gameLibrary = route {
                        coordinator.navigateAndClearPath(to: route)
                    } else {
                        coordinator.navigate(to: route)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func customNavigationBar(topInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    coordinator.pop()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.text)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.sm)
            .padding(.top, topInset + Spacing.sm)
            
            Divider()
                .background(AppTheme.Colors.text.opacity(0.2))
        }
        .background(AppTheme.Colors.darkBlue)
    }
    
}
#Preview {
    UserInformationView(email: "test@example.com", password: "password123")
        .environmentObject(AppCoordinator())
}
