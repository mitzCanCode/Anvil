//
//  CodeStatsCardView.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 27/8/25.
//

import SwiftUI

struct CodeStatsCardView: View {
    let title: String
    let stats: [(key: String, value: String, icon: String)]
    let isLoading: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title with coding style
            HStack {
                Text(title + " {")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                    .monospaced()
                
                Spacer()
            }
            
            if isLoading {
                // Loading skeleton
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<5, id: \.self) { _ in
                        HStack {
                            Text("  \"")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .monospaced()
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 80, height: 16)
                                .redacted(reason: .placeholder)
                            
                            Text("\": ")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .monospaced()
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 16)
                                .redacted(reason: .placeholder)
                            
                            Text(",")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .monospaced()
                            
                            Spacer()
                        }
                    }
                }
            } else {
                // Stats content
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                        HStack(spacing: 4) {
                            Text("  \"")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .monospaced()
                            
                            Image(systemName: stat.icon)
                                .font(.caption)
                                .foregroundColor(.purple)
                            
                            Text(stat.key)
                                .font(.body)
                                .foregroundColor(.purple)
                                .fontWeight(.medium)
                                .monospaced()
                            
                            Text("\": ")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .monospaced()
                            
                            Text(stat.value)
                                .font(.body)
                                .foregroundColor(.purple)
                                .fontWeight(.semibold)
                                .monospaced()
                            
                            Text(index == stats.count - 1 ? "" : ",")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .monospaced()
                            
                            Spacer()
                        }
                    }
                }
            }
            
            // Closing brace
            Text("}")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.purple)
                .monospaced()
        }
        .padding(20)
        .background(.ultraThinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 16))
        .background(Color.gray.opacity(colorScheme == .dark ? 0.3 : 0.2), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple.opacity(0.3), lineWidth: 7)
        )
        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
    }
}

struct SkeletonCodeStatsCardView: View {
    let title: String
    
    var body: some View {
        CodeStatsCardView(
            title: title,
            stats: [], // Empty for loading state
            isLoading: true
        )
    }
}

// MARK: - Preview

#Preview("Code Stats Card") {
    VStack(spacing: 16) {
        CodeStatsCardView(
            title: "My_repositories",
            stats: [
                (key: "public_repos", value: "15", icon: "folder"),
                (key: "private_repos", value: "8", icon: "lock.fill"),
                (key: "stars", value: "124", icon: "star.fill"),
                (key: "open_issues", value: "7", icon: "exclamationmark.circle"),
                (key: "open_prs", value: "3", icon: "arrow.triangle.pull")
            ],
            isLoading: false
        )
        
        SkeletonCodeStatsCardView(title: "Other_repositories")
    }
    .padding()
}
