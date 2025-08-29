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
        .background(.thinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 16))
        .background(color.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 8)
        )
        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
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
                .stroke(Color.purple.opacity(0.3), lineWidth: 7)
        )
    }
    
    private func languageColor(for language: String) -> Color {
        switch language.lowercased() {
        // GitHub official language colors
        case "swift": return Color(red: 0.98, green: 0.36, blue: 0.11) // #FA5B2D
        case "python": return Color(red: 0.22, green: 0.49, blue: 0.72) // #3776AB
        case "javascript": return Color(red: 0.95, green: 0.84, blue: 0.15) // #F1E05A
        case "typescript": return Color(red: 0.18, green: 0.39, blue: 0.73) // #2F74C0
        case "java": return Color(red: 0.69, green: 0.33, blue: 0.13) // #B07219
        case "kotlin": return Color(red: 0.63, green: 0.47, blue: 1.0) // #A97BFF
        case "go": return Color(red: 0.00, green: 0.68, blue: 0.94) // #00ADD8
        case "rust": return Color(red: 0.87, green: 0.38, blue: 0.11) // #DEA584
        case "c++": return Color(red: 0.95, green: 0.30, blue: 0.44) // #F34B7D
        case "c": return Color(red: 0.34, green: 0.34, blue: 0.34) // #555555
        case "ruby": return Color(red: 0.44, green: 0.09, blue: 0.09) // #701516
        case "php": return Color(red: 0.31, green: 0.40, blue: 0.68) // #4F5D95
        case "html": return Color(red: 0.89, green: 0.30, blue: 0.18) // #E34C26
        case "css": return Color(red: 0.09, green: 0.42, blue: 0.80) // #1572B6
        case "shell": return Color(red: 0.54, green: 0.67, blue: 0.22) // #89E051
        case "objective-c": return Color(red: 0.27, green: 0.39, blue: 0.71) // #438EFF
        case "c#": return Color(red: 0.15, green: 0.46, blue: 0.02) // #239120
        case "dart": return Color(red: 0.00, green: 0.69, blue: 0.93) // #00B4AB
        case "scala": return Color(red: 0.78, green: 0.25, blue: 0.23) // #C22D40
        case "r": return Color(red: 0.31, green: 0.51, blue: 0.71) // #198CE7
        case "matlab": return Color(red: 0.88, green: 0.41, blue: 0.05) // #E16737
        case "vue": return Color(red: 0.25, green: 0.72, blue: 0.32) // #41B883
        case "haskell": return Color(red: 0.36, green: 0.31, blue: 0.60) // #5E4F87
        case "lua": return Color(red: 0.00, green: 0.00, blue: 0.50) // #000080
        case "perl": return Color(red: 0.02, green: 0.31, blue: 0.60) // #0298C3
        case "powershell": return Color(red: 0.01, green: 0.22, blue: 0.39) // #012456
        case "dockerfile": return Color(red: 0.23, green: 0.56, blue: 0.98) // #384D54
        case "yaml", "yml": return Color(red: 0.80, green: 0.12, blue: 0.26) // #CB171E
        case "json": return Color(red: 0.17, green: 0.17, blue: 0.17) // #292929
        case "xml": return Color(red: 0.00, green: 0.40, blue: 0.20) // #0060AC
        case "markdown", "md": return Color(red: 0.08, green: 0.17, blue: 0.32) // #083FA1
        default: return Color.gray
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
        .background(.thinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 16))
        .background(color.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 8)
        )
        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
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
                    .stroke(Color.purple.opacity(0.3), lineWidth: 7)
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
            openPullRequests: 2,
            languageStats: []
        )
    )
    .padding()
}
