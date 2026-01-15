//
//  ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel = ProfileViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    if let profile = viewModel.profile {
                        Text(profile.name)
                            .font(.title)
                            .bold()
                        
                        Text(profile.email)
                            .foregroundColor(.gray)
                    }
                    
                    if let stats = viewModel.gamingStats {
                        Text("Games Played: \(stats.gamesPlayed)")
                        Text("Total Play Time: \(stats.totalPlayTime) hours")
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .onAppear {
                viewModel.fetchProfile()
            }
        }
    }
}

#Preview {
    ProfileView(viewModel: ProfileViewModel())
}

