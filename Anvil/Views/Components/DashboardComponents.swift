//
//  DashboardComponents.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 27/8/25.
//

import SwiftUI

// MARK: - Stat Card Component

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Repository Card Component

struct RepositoryCardView: View {
    let repositoryStats: RepositoryStats
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Repository Icon
            VStack {
                Image(systemName: repositoryStats.repository.isPrivate ? "lock.fill" : "folder.fill")
                    .font(.title2)
                    .foregroundColor(repositoryStats.repository.isPrivate ? .orange : .blue)
            }
            
            // Repository Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(repositoryStats.repository.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if repositoryStats.repository.stargazersCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text("\(repositoryStats.repository.stargazersCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let description = repositoryStats.repository.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 16) {
                    if repositoryStats.openIssues > 0 {
                        Label("\(repositoryStats.openIssues)", systemImage: "exclamationmark.circle")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    if repositoryStats.openPullRequests > 0 {
                        Label("\(repositoryStats.openPullRequests)", systemImage: "arrow.triangle.pull")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    if let language = repositoryStats.repository.language {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(languageColor(for: language))
                                .frame(width: 8, height: 8)
                            Text(language)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func languageColor(for language: String) -> Color {
        switch language.lowercased() {
        case "swift": return .orange
        case "python": return .yellow
        case "javascript", "typescript": return .yellow
        case "java": return .red
        case "kotlin": return .purple
        case "go": return .cyan
        case "rust": return .orange
        case "c++", "c": return .blue
        case "ruby": return .red
        case "php": return .purple
        default: return .gray
        }
    }
}

// MARK: - Skeleton Loading Components

struct SkeletonStatCardView: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 28)
                    .redacted(reason: .placeholder)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct SkeletonRepositoryCardView: View {
    var body: some View {
        HStack(spacing: 12) {
            // Repository Icon
            VStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .redacted(reason: .placeholder)
            }
            
            // Repository Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 18)
                        .redacted(reason: .placeholder)
                    
                    Spacer()
                }
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 180, height: 14)
                    .redacted(reason: .placeholder)
                
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 12)
                        .redacted(reason: .placeholder)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 12)
                        .redacted(reason: .placeholder)
                    
                    Spacer()
                }
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Extensions

extension RepositoryStats: Identifiable {
    var id: Int { repository.id }
}

// MARK: - Preview

#Preview("Stat Card") {
    StatCardView(
        title: "Public Repos",
        value: "42",
        icon: "folder",
        color: .blue
    )
    .padding()
}

#Preview("Repository Card") {
    RepositoryCardView(
        repositoryStats: RepositoryStats(
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
            openPullRequests: 2
        )
    )
    .padding()
}
