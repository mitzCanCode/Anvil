//
//  DashboardView.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 24/8/25.
//

import SwiftUI

struct DashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var loadingState = DashboardLoadingState()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // User Profile Card
                    UserProfileCardView(
                        user: loadingState.userInfo,
                        isLoading: loadingState.isLoading
                    )
                    
                    if let errorMessage = loadingState.errorMessage {
                        ErrorView(message: errorMessage) {
                            await refreshData()
                        }
                    } else {
                        // My Repositories Section
                        RepositorySectionView(
                            title: "My Repositories",
                            icon: "person.crop.circle",
                            iconColor: .blue,
                            repositories: loadingState.myRepositories,
                            isLoading: loadingState.isLoading
                        )
                        
                        // Other Repositories Section
                        if !loadingState.otherRepositories.isEmpty || loadingState.isLoading {
                            RepositorySectionView(
                                title: "Other Repositories",
                                icon: "globe",
                                iconColor: .purple,
                                repositories: loadingState.otherRepositories,
                                isLoading: loadingState.isLoading,
                                isOtherRepos: true
                            )
                        }
                        
                        // Social Stats
                        SocialStatsView(
                            user: loadingState.userInfo,
                            isLoading: loadingState.isLoading
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.blue.opacity(colorScheme == .dark ? 0.1 : 0.3),
                        Color.purple.opacity(colorScheme == .dark ? 0.1 : 0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Dashboard")
            .refreshable {
                await refreshData()
            }
            .onAppear {
                Task {
                    await loadDataIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadDataIfNeeded() async {
        guard loadingState.userInfo == nil else { return }
        await refreshData()
    }
    
    private func refreshData() async {
        guard let token = authViewModel.loadOAuthToken() else {
            await MainActor.run {
                loadingState.errorMessage = "No OAuth token found. Please sign in again."
            }
            return
        }
        
        await loadingState.loadData(with: token)
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
