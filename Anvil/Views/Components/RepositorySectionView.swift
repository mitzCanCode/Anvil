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
    
    @Environment(\.colorScheme) var colorScheme
    @State private var showingAllRepositories = false
    
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
    
    private var stats: (public: Int, private: Int, stars: Int, issues: Int, prs: Int) {
        repositories.reduce((0, 0, 0, 0, 0)) { result, repo in
            (
                result.0 + (repo.repository.isPrivate ? 0 : 1),
                result.1 + (repo.repository.isPrivate ? 1 : 0),
                result.2 + repo.repository.stargazersCount,
                result.3 + repo.openIssues,
                result.4 + repo.openPullRequests
            )
        }
    }
    
    @ViewBuilder
    private var repositoryList: some View {
        if isLoading {
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    SkeletonCodeRepoButtonView()
                }
            }
        } else if repositories.isEmpty {
            Text("// No repositories found...")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
                .monospaced()
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 12))
                .background(Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.15), in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 7)
                )
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        } else {
            VStack(spacing: 12) {
                ForEach(Array(repositories.prefix(3))) { repository in
                    CodeRepoButtonView(repositoryStats: repository)
                }
                
                if repositories.count > 3 {
                    Button("// and \(repositories.count - 3) more repositories...") {
                        showingAllRepositories = true
                    }
                    .font(.caption)
                    .foregroundColor(.purple)
                    .italic()
                    .monospaced()
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 12))
                    .background(Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.15), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.purple.opacity(0.3), lineWidth: 7)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                }
            }
            
            if isLoading {
                SkeletonCodeStatsCardView(title: isOtherRepos ? "Other_repositories" : "My_repositories")
            } else {
                let computedStats = stats
                CodeStatsCardView(
                    title: isOtherRepos ? "Other_repositories" : "My_repositories",
                    stats: [
                        (key: "total_repos", value: "\(repositories.count)", icon: "folder.badge.gearshape"),
                        (key: "public_repos", value: "\(computedStats.public)", icon: "folder"),
                        (key: "private_repos", value: "\(computedStats.private)", icon: "lock.fill"),
                        (key: "stars", value: "\(computedStats.stars)", icon: "star.fill"),
                        (key: "open_issues", value: "\(computedStats.issues)", icon: "exclamationmark.circle"),
                        (key: "open_prs", value: "\(computedStats.prs)", icon: "arrow.triangle.pull")
                    ],
                    isLoading: false
                )
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(isOtherRepos ? "Recent Contributions" : "Recent")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                repositoryList
            }
        }
        .sheet(isPresented: $showingAllRepositories) {
            AllRepositoriesView(
                title: title,
                repositories: repositories
            )
        }
    }
}
