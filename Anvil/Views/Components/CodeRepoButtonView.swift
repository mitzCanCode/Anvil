//
//  CodeRepoButtonView.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 27/8/25.
//

import SwiftUI

struct CodeRepoButtonView: View {
    let repositoryStats: RepositoryStats
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    
    private var topLanguages: [(name: String, percentage: String)] {
        repositoryStats.languageStats.prefix(3).map { lang in
            (name: lang.name, percentage: String(format: "%.1f%%", lang.percentage))
        }
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
    
    var body: some View {
        Button(action: {
            if let url = URL(string: repositoryStats.repository.htmlUrl) {
                openURL(url)
            }
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // Header with name and privacy indicator
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(repositoryStats.repository.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        if let description = repositoryStats.repository.description, !description.isEmpty {
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                    
                    if repositoryStats.repository.isPrivate {
                        VStack {
                            Image(systemName: "lock")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Statistics row
                HStack(spacing: 20) {
                    if repositoryStats.repository.stargazersCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text("\(repositoryStats.repository.stargazersCount)")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                    
                    if repositoryStats.repository.forksCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "tuningfork")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text("\(repositoryStats.repository.forksCount)")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                    
                    if repositoryStats.openIssues > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.circle")
                                .font(.caption)
                                .foregroundColor(.red)
                            Text("\(repositoryStats.openIssues)")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                    
                    if repositoryStats.openPullRequests > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.pull")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("\(repositoryStats.openPullRequests)")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                    
                    Spacer()
                }
                
                // Languages section
                if !topLanguages.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Languages")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            ForEach(Array(topLanguages.enumerated()), id: \.offset) { _, lang in
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(languageColor(for: lang.name))
                                        .frame(width: 8, height: 8)
                                    Text(lang.name)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text(lang.percentage)
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                            }
                            Spacer()
                        }
                    }
                } else {
                    HStack {
                        Text("No language data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(.ultraThinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 12))
            .background(Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.15), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 8)
            )
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

struct SkeletonCodeRepoButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header skeleton
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 140, height: 18)
                        .redacted(reason: .placeholder)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 200, height: 14)
                        .redacted(reason: .placeholder)
                }
                
                Spacer()
                
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .redacted(reason: .placeholder)
            }
            
            // Statistics row skeleton
            HStack(spacing: 20) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 12, height: 12)
                            .redacted(reason: .placeholder)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 20, height: 12)
                            .redacted(reason: .placeholder)
                    }
                }
                Spacer()
            }
            
            // Languages section skeleton
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 12)
                    .redacted(reason: .placeholder)
                
                HStack(spacing: 12) {
                    ForEach(0..<2, id: \.self) { _ in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .redacted(reason: .placeholder)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 10)
                                .redacted(reason: .placeholder)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 30, height: 10)
                                .redacted(reason: .placeholder)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 12))
        .background(Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.15), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.3), lineWidth: 8)
        )
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preview

#Preview("Code Repo Button") {
    VStack(spacing: 12) {
        CodeRepoButtonView(
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
                languageStats: [
                    LanguageStats(name: "Swift", percentage: 65.2, bytes: 45320),
                    LanguageStats(name: "JavaScript", percentage: 24.8, bytes: 17234),
                    LanguageStats(name: "CSS", percentage: 10.0, bytes: 6950)
                ]
            )
        )
        
        CodeRepoButtonView(
            repositoryStats: RepositoryStats(
                repository: GitHubRepository(
                    id: 2,
                    name: "no-language-repo",
                    fullName: "user/no-language-repo",
                    isPrivate: true,
                    stargazersCount: 0,
                    openIssuesCount: 0,
                    forksCount: 0,
                    language: nil,
                    description: nil,
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
        )
        
        SkeletonCodeRepoButtonView()
    }
    .padding()
}
