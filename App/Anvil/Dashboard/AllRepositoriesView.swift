//
//  AllRepositoriesView.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 27/8/25.
//

import SwiftUI

struct AllRepositoriesView: View {
    let title: String
    let repositories: [RepositoryStats]
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(repositories) { repository in
                        CodeRepoButtonView(repositoryStats: repository)
                    }
                }
                .padding()
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
            .navigationTitle(title)
        }
    }
}

// MARK: - Preview

#Preview("All Repositories") {
    AllRepositoriesView(
        title: "My Repositories",
        repositories: [
            RepositoryStats(
                repository: GitHubRepository(
                    id: 1,
                    name: "awesome-project",
                    fullName: "user/awesome-project",
                    isPrivate: false,
                    stargazersCount: 42,
                    openIssuesCount: 5,
                    forksCount: 10,
                    language: "Swift",
                    description: "An awesome project that does amazing things",
                    htmlUrl: "https://github.com/user/awesome-project",
                    createdAt: "2024-01-01",
                    updatedAt: "2024-08-27",
                    owner: RepositoryOwner(
                        id: 12345,
                        login: "user",
                        avatarUrl: "https://github.com/user.png"
                    ),
                    isFork: false
                ),
                openIssues: 3,
                openPullRequests: 2,
                languageStats: []
            ),
            RepositoryStats(
                repository: GitHubRepository(
                    id: 2,
                    name: "no-language-repo",
                    fullName: "user/no-language-repo",
                    isPrivate: true,
                    stargazersCount: 0,
                    openIssuesCount: 0,
                    forksCount: 0,
                    language: nil,
                    description: "A repository without language information",
                    htmlUrl: "https://github.com/user/no-language-repo",
                    createdAt: "2024-01-01",
                    updatedAt: "2024-08-27",
                    owner: RepositoryOwner(
                        id: 12345,
                        login: "user",
                        avatarUrl: "https://github.com/user.png"
                    ),
                    isFork: false
                ),
                openIssues: 0,
                openPullRequests: 0,
                languageStats: []
            )
        ]
    )
}
