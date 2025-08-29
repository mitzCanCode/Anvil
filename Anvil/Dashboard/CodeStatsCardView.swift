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
        VStack(alignment: .leading, spacing: 16) {
            // Title section
            HStack {
                Text(title.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            if isLoading {
                // Loading skeleton in 2-column grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 12) {
                    ForEach(0..<6, id: \.self) { _ in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 16, height: 16)
                                .shimmer(duration: 1.6, highlight: .white.opacity(0.5))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 60, height: 12)
                                    .shimmer(duration: 1.6, highlight: .white.opacity(0.5))
                                
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 30, height: 10)
                                    .shimmer(duration: 1.6, highlight: .white.opacity(0.5))
                            }
                            
                            Spacer(minLength: 0)
                        }
                    }
                }
            } else {
                // Stats content in 2 columns with proper grouping
                HStack(alignment: .top, spacing: 16) {
                    // Left column (first half of stats)
                    VStack(spacing: 12) {
                        ForEach(Array(stats.prefix(3).enumerated()), id: \.offset) { _, stat in
                            HStack(spacing: 8) {
                                Image(systemName: stat.icon)
                                    .font(.subheadline)
                                    .foregroundColor(.purple)
                                    .frame(width: 16)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(stat.key.replacingOccurrences(of: "_", with: " ").capitalized)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    
                                    Text(stat.value)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer(minLength: 0)
                            }
                        }
                    }
                    
                    // Right column (second half of stats)
                    VStack(spacing: 12) {
                        ForEach(Array(stats.suffix(3).enumerated()), id: \.offset) { _, stat in
                            HStack(spacing: 8) {
                                Image(systemName: stat.icon)
                                    .font(.subheadline)
                                    .foregroundColor(.purple)
                                    .frame(width: 16)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(stat.key.replacingOccurrences(of: "_", with: " ").capitalized)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    
                                    Text(stat.value)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer(minLength: 0)
                            }
                        }
                    }
                }
            }
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
