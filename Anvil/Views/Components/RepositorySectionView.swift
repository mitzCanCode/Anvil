//
//  RepositorySectionView.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 27/8/25.
//

import SwiftUI

struct RepositorySectionView: View {
    let title: String
    let icon: String
    let iconColor: Color
    let repositories: [RepositoryStats]
    let isLoading: Bool
    let isOtherRepos: Bool
    
    init(
        title: String,
        icon: String,
        iconColor: Color,
        repositories: [RepositoryStats],
        isLoading: Bool,
        isOtherRepos: Bool = false
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.repositories = repositories
        self.isLoading = isLoading
        self.isOtherRepos = isOtherRepos
    }
    
    private var publicRepos: Int {
        repositories.filter { !$0.repository.isPrivate }.count
    }
    
    private var privateRepos: Int {
        repositories.filter { $0.repository.isPrivate }.count
    }
    
    private var totalStars: Int {
        repositories.reduce(0) { $0 + $1.repository.stargazersCount }
    }
    
    private var openIssues: Int {
        repositories.reduce(0) { $0 + $1.openIssues }
    }
    
    private var openPRs: Int {
        repositories.reduce(0) { $0 + $1.openPullRequests }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text("\(repositories.count) repos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Stats Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                if isLoading {
                    SkeletonStatCardView(title: "Public Repos", icon: "folder", color: .blue)
                    SkeletonStatCardView(title: "Private Repos", icon: "lock.fill", color: .orange)
                    SkeletonStatCardView(title: "Stars", icon: "star.fill", color: .yellow)
                    SkeletonStatCardView(title: "Open Issues", icon: "exclamationmark.circle", color: .red)
                    SkeletonStatCardView(title: "Open PRs", icon: "arrow.triangle.pull", color: .green)
                } else {
                    StatCardView(
                        title: "Public Repos",
                        value: "\(publicRepos)",
                        icon: "folder",
                        color: .blue
                    )
                    
                    StatCardView(
                        title: "Private Repos",
                        value: "\(privateRepos)",
                        icon: "lock.fill",
                        color: .orange
                    )
                    
                    StatCardView(
                        title: "Stars",
                        value: "\(totalStars)",
                        icon: "star.fill",
                        color: .yellow
                    )
                    
                    StatCardView(
                        title: "Open Issues",
                        value: "\(openIssues)",
                        icon: "exclamationmark.circle",
                        color: .red
                    )
                    
                    StatCardView(
                        title: "Open PRs",
                        value: "\(openPRs)",
                        icon: "arrow.triangle.pull",
                        color: .green
                    )
                }
            }
            
            // Recent Repositories
            if isLoading || !repositories.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(isOtherRepos ? "Recent Contributions" : "Recent")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    if isLoading {
                        LazyVStack(spacing: 8) {
                            ForEach(0..<3, id: \.self) { _ in
                                SkeletonRepositoryCardView()
                            }
                        }
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(Array(repositories.prefix(3))) { repository in
                                RepositoryCardView(repositoryStats: repository)
                            }
                            
                            if repositories.count > 3 {
                                Text("and \(repositories.count - 3) more...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                    }
                }
            }
        }
    }
}
