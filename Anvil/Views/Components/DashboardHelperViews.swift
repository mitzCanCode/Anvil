//
//  DashboardHelperViews.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 27/8/25.
//

import SwiftUI

// MARK: - Error View

struct ErrorView: View {
    let message: String
    let onRetry: () async -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Unable to load GitHub data")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await onRetry()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Social Stats View

struct SocialStatsView: View {
    let user: GitHubUser?
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.2")
                    .font(.title2)
                    .foregroundColor(.indigo)
                
                Text("Social")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                if isLoading {
                    SkeletonStatCardView(title: "Followers", icon: "person.2.fill", color: .purple)
                    SkeletonStatCardView(title: "Following", icon: "person.badge.plus", color: .indigo)
                } else if let user = user {
                    StatCardView(
                        title: "Followers",
                        value: "\(user.followers)",
                        icon: "person.2.fill",
                        color: .purple
                    )
                    
                    StatCardView(
                        title: "Following",
                        value: "\(user.following)",
                        icon: "person.badge.plus",
                        color: .indigo
                    )
                } else {
                    SkeletonStatCardView(title: "Followers", icon: "person.2.fill", color: .purple)
                    SkeletonStatCardView(title: "Following", icon: "person.badge.plus", color: .indigo)
                }
            }
        }
    }
}
