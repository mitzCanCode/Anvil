//
//  UserProfileCardView.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 27/8/25.
//

import SwiftUI

struct UserProfileCardView: View {
    let user: GitHubUser?
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
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Loading Content
    
    private var loadingContent: some View {
        VStack(spacing: 16) {
            // Avatar and basic info skeleton
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .redacted(reason: .placeholder)
                
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 140, height: 24)
                        .redacted(reason: .placeholder)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 16)
                        .redacted(reason: .placeholder)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 16)
                        .redacted(reason: .placeholder)
                }
                
                Spacer()
            }
            
            // Stats skeleton
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 20)
                            .redacted(reason: .placeholder)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 12)
                            .redacted(reason: .placeholder)
                    }
                }
            }
        }
        .padding(20)
    }
    
    // MARK: - User Content
    
    private func userContent(_ user: GitHubUser) -> some View {
        VStack(spacing: 20) {
            // Header with avatar and basic info
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: user.avatarUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 6) {
                    // Name
                    if let name = user.name, !name.isEmpty {
                        Text(name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    // Username
                    Text("@\(user.login)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Location
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
                    
                    // Company
                    if let company = user.company, !company.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "building.2")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(company.replacingOccurrences(of: "@", with: ""))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Bio
            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Social Stats
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                statItem(
                    title: "Followers",
                    value: "\(user.followers)",
                    icon: "person.2.fill",
                    color: .purple
                )
                
                statItem(
                    title: "Following",
                    value: "\(user.following)",
                    icon: "person.badge.plus",
                    color: .blue
                )
                
                statItem(
                    title: "Repositories",
                    value: "\(user.publicRepos)",
                    icon: "folder.fill",
                    color: .green
                )
            }
            
            // Links and Contact Info
            if hasContactInfo(user) {
                Divider()
                    .padding(.vertical, 8)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 12) {
                    // Website/Blog
                    if let blog = user.blog, !blog.isEmpty, let url = URL(string: blog.hasPrefix("http") ? blog : "https://\(blog)") {
                        contactButton(
                            title: "Website",
                            icon: "link",
                            color: .orange
                        ) {
                            openURL(url)
                        }
                    }
                    
                    // Twitter
                    if let twitter = user.twitterUsername, !twitter.isEmpty {
                        contactButton(
                            title: "Twitter",
                            icon: "bird.fill",
                            color: .blue
                        ) {
                            if let url = URL(string: "https://twitter.com/\(twitter)") {
                                openURL(url)
                            }
                        }
                    }
                    
                    // Email
                    if let email = user.email, !email.isEmpty {
                        contactButton(
                            title: "Email",
                            icon: "envelope.fill",
                            color: .red
                        ) {
                            if let url = URL(string: "mailto:\(email)") {
                                openURL(url)
                            }
                        }
                    }
                    
                    // GitHub Profile
                    contactButton(
                        title: "GitHub",
                        icon: "chevron.left.forwardslash.chevron.right",
                        color: .gray
                    ) {
                        if let url = URL(string: "https://github.com/\(user.login)") {
                            openURL(url)
                        }
                    }
                }
            }
            
            // Additional Info
            if hasAdditionalInfo(user) {
                Divider()
                    .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional Information")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 6) {
                        // Hireable status
                        if let hireable = user.hireable, hireable {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text("Available for hire")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                        
                        // Join date
                        if let joinDate = formatJoinDate(user.createdAt) {
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Joined \(joinDate)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                        
                        // Public Gists
                        if user.publicGists > 0 {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.text")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(user.publicGists) public gists")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
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
                    .stroke(color.opacity(0.3), lineWidth: 1)
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
        isLoading: false
    )
    .padding()
}

#Preview("User Profile Card Loading") {
    UserProfileCardView(
        user: nil,
        isLoading: true
    )
    .padding()
}
