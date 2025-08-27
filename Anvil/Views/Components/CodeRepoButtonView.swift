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
            (name: lang.name.lowercased(), percentage: String(format: "%.1f%%", lang.percentage))
        }
    }
    
    @ViewBuilder
    private var repositoryDetailsView: some View {
        HStack {
            Text("    \"issues\": \(repositoryStats.openIssues),")
                .font(.caption)
                .foregroundColor(.secondary)
                .monospaced()
            Spacer()
        }
        
        HStack {
            Text("    \"stars\": \(repositoryStats.repository.stargazersCount),")
                .font(.caption)
                .foregroundColor(.secondary)
                .monospaced()
            Spacer()
        }
        
        HStack {
            Text("    \"forks\": \(repositoryStats.repository.forksCount),")
                .font(.caption)
                .foregroundColor(.secondary)
                .monospaced()
            Spacer()
        }
    }
    
    @ViewBuilder
    private var privateStatusView: some View {
        HStack {
            Text("    \"private\": ")
                .font(.caption)
                .foregroundColor(.secondary)
                .monospaced()
            
            Text(repositoryStats.repository.isPrivate ? "true" : "false")
                .font(.caption)
                .foregroundColor(repositoryStats.repository.isPrivate ? .red : .green)
                .fontWeight(.semibold)
                .monospaced()
            
            Text(",")
                .font(.caption)
                .foregroundColor(.secondary)
                .monospaced()
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var languagesView: some View {
        HStack {
            Text("    \"languages\": {")
                .font(.caption)
                .foregroundColor(.secondary)
                .monospaced()
            Spacer()
        }
        
        if topLanguages.isEmpty {
            HStack {
                Text("        \"no_language\": \"unknown\"")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .monospaced()
                Spacer()
            }
        } else {
            ForEach(Array(topLanguages.enumerated()), id: \.offset) { index, lang in
                HStack {
                    Text("        \"\(lang.name)\": \"\(lang.percentage)\"\(index < topLanguages.count - 1 ? "," : "")")
                        .font(.caption)
                        .foregroundColor(.purple)
                        .fontWeight(.medium)
                        .monospaced()
                    Spacer()
                }
            }
        }
        
        HStack {
            Text("    }")
                .font(.caption)
                .foregroundColor(.secondary)
                .monospaced()
            Spacer()
        }
    }
    
    var body: some View {
        Button(action: {
            if let url = URL(string: repositoryStats.repository.htmlUrl) {
                openURL(url)
            }
        }) {
            VStack(alignment: .leading, spacing: 6) {
                if let description = repositoryStats.repository.description, !description.isEmpty {
                    Text("// " + description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                        .lineLimit(2)
                        .monospaced()
                }
                
                HStack {
                    Text("\"" + repositoryStats.repository.name + "\": {")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                        .monospaced()
                    
                    Spacer()
                }
                
                repositoryDetailsView
                
                privateStatusView
                
                languagesView
                
                Text("}")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                    .monospaced()
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
        VStack(alignment: .leading, spacing: 6) {
            // Repository name skeleton
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 16)
                    .redacted(reason: .placeholder)
                
                Text(": {")
                    .font(.body)
                    .foregroundColor(.purple)
                    .fontWeight(.bold)
                    .monospaced()
                
                Spacer()
            }
            
            // Issues skeleton
            HStack {
                Text("    \"issues\": ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospaced()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 20, height: 12)
                    .redacted(reason: .placeholder)
                
                Text(",")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospaced()
                
                Spacer()
            }
            
            // Stars skeleton
            HStack {
                Text("    \"stars\": ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospaced()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 25, height: 12)
                    .redacted(reason: .placeholder)
                
                Text(",")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospaced()
                
                Spacer()
            }
            
            // Forks skeleton
            HStack {
                Text("    \"forks\": ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospaced()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 15, height: 12)
                    .redacted(reason: .placeholder)
                
                Text(",")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospaced()
                
                Spacer()
            }
            
            // Languages object skeleton
            HStack {
                Text("    \"languages\": {")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospaced()
                
                Spacer()
            }
            
            // Language info skeleton
            HStack {
                Text("        \"")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospaced()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 12)
                    .redacted(reason: .placeholder)
                
                Text("\": \"")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospaced()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 35, height: 12)
                    .redacted(reason: .placeholder)
                
                Text("\"")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospaced()
                
                Spacer()
            }
            
            // Close languages object
            HStack {
                Text("    }")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospaced()
                
                Spacer()
            }
            
            // Closing main object brace
            Text("}")
                .font(.body)
                .foregroundColor(.purple)
                .fontWeight(.bold)
                .monospaced()
        }
        .padding(16)
        .background(.ultraThinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 12))
        .background(Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.15), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.3), lineWidth: 7)
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
