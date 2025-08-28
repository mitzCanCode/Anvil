//
//  UserProfileCardView.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 27/8/25.
//

import SwiftUI

struct UserProfileCardView: View {
    let user: GitHubUser?
    let totalRepositories: Int
    let isLoading: Bool
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                loadingContent
            } else if let user = user {
                userContent(user)
            } else {
                emptyContent
            }
        }
        .background(.ultraThinMaterial.blendMode(.overlay), in: RoundedRectangle(cornerRadius: 20))
        .background(
            Color.gray.opacity(colorScheme == .dark ? 0.3 : 0.2),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color.purple.opacity(0.3),
                    lineWidth: 8
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Loading Content
    
    private var loadingContent: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                // Name skeleton
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 140, height: 20)
                    .shimmer(duration: 1.8, highlight: .white.opacity(0.4))
                
                // Bio skeleton
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 180, height: 12)
                        .shimmer(duration: 1.8, highlight: .white.opacity(0.4))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 12)
                        .shimmer(duration: 1.8, highlight: .white.opacity(0.4))
                }
                
                // Stats skeleton
                HStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { _ in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 30, height: 16)
                                .shimmer(duration: 1.8, highlight: .white.opacity(0.4))
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 10)
                                .shimmer(duration: 1.8, highlight: .white.opacity(0.4))
                        }
                    }
                    Spacer()
                }
            }
            
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 80)
                .shimmer(duration: 1.8, highlight: .white.opacity(0.4))
        }
        .padding()
    }
    
    // MARK: - User Content
    
    private func userContent(_ user: GitHubUser) -> some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                // Header section
                VStack(alignment: .leading, spacing: 8) {
                    if let name = user.name, !name.isEmpty {
                        Text(name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Text("@" + user.login)
                        .font(.subheadline)
                        .foregroundColor(.purple)
                        .fontWeight(.medium)
                    
                    if let bio = user.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    if let location = user.location, !location.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Stats section
                HStack(spacing: 20) {
                    statItem(title: "Followers", value: "\(user.followers)", icon: "person.2", color: .blue)
                    statItem(title: "Following", value: "\(user.following)", icon: "person.badge.plus", color: .green)
                    statItem(title: "Repos", value: "\(totalRepositories)", icon: "folder", color: .purple)
                }
                
                // Additional info
                VStack(alignment: .leading, spacing: 6) {
                    if let hireable = user.hireable, hireable {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("Available for hire")
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        }
                    }
                    
                    if let joinDate = formatJoinDate(user.createdAt) {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Joined \(joinDate)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            AsyncImage(url: URL(string: user.avatarUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                case .failure(_), .empty:
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                @unknown default:
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                }
            }
            .overlay(
                Circle()
                .stroke(Color.purple.opacity(0.3), lineWidth: 7)
            )
        }
        .padding()
    }
    
    // MARK: - Empty Content
    
    private var emptyContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("Welcome to Anvil")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your GitHub profile will appear here once loaded")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    // MARK: - Helper Views
    
    private func statItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func contactButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color.opacity(0.3), lineWidth: 4)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helper Functions
    
    private func hasContactInfo(_ user: GitHubUser) -> Bool {
        return (user.blog != nil && !user.blog!.isEmpty) ||
               (user.twitterUsername != nil && !user.twitterUsername!.isEmpty) ||
               (user.email != nil && !user.email!.isEmpty)
    }
    
    private func hasAdditionalInfo(_ user: GitHubUser) -> Bool {
        return (user.hireable == true) || user.publicGists > 0
    }
    
    private func formatJoinDate(_ dateString: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        guard let date = formatter.date(from: dateString) else { return nil }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM yyyy"
        return outputFormatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("User Profile Card") {
    UserProfileCardView(
        user: GitHubUser(
            id: 12345,
            login: "developer",
            name: "John Developer",
            publicRepos: 25,
            publicGists: 8,
            followers: 150,
            following: 75,
            avatarUrl: "https://avatars.githubusercontent.com/u/12345?v=4",
            bio: "iOS Developer passionate about creating amazing user experiences with Swift and SwiftUI. Always learning new technologies.",
            location: "San Francisco, CA",
            company: "@TechCorp",
            blog: "https://johndeveloper.dev",
            email: "john@example.com",
            twitterUsername: "johndev",
            hireable: true,
            createdAt: "2020-03-15T10:30:00Z",
            updatedAt: "2024-08-27T14:20:00Z"
        ),
        totalRepositories: 42,
        isLoading: false
    )
    .padding()
}

#Preview("User Profile Card Loading") {
    UserProfileCardView(
        user: nil,
        totalRepositories: 0,
        isLoading: true
    )
    .padding()
}



