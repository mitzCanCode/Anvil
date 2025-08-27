//
//  DashboardView.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 24/8/25.
//

import SwiftUI

struct DashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Progressive loading states
    @State private var userInfo: GitHubUser?
    @State private var myRepositoryStats: [RepositoryStats] = []
    @State private var otherRepositoryStats: [RepositoryStats] = []
    
    // Loading states for each section
    @State private var isLoadingUserInfo = true
    @State private var isLoadingMyRepos = true
    @State private var isLoadingOtherRepos = true
    
    @State private var errorMessage: String?
    
    // Task management for cancellation
    @State private var loadingTask: Task<Void, Never>?
    
    private let gitHubService = GitHubFetches()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // User Profile Card
                    userProfileCard
                    
                    if let errorMessage = errorMessage {
                        errorView(errorMessage)
                    } else {
                        // My Repositories Section
                        myRepositoriesSection
                        
                        // Other Repositories Section (only show if we have data or are still loading)
                        if !otherRepositoryStats.isEmpty || isLoadingOtherRepos {
                            otherRepositoriesSection
                        }
                        
                        // Social Stats
                        socialStatsView
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
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
            .navigationTitle("Dashboard")
            .refreshable {
                await loadGitHubDataProgressively()
            }
            .onAppear {
                Task {
                    await loadGitHubDataProgressively()
                }
            }
        }
    }
    
    // MARK: - User Profile Card
    
    private var userProfileCard: some View {
        UserProfileCardView(user: userInfo, isLoading: isLoadingUserInfo)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading GitHub data...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Error View
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Unable to load GitHub data")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await loadGitHubDataProgressively()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Overview Stats View
    
    private func overviewStatsView(_ summary: UserSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                StatCardView(
                    title: "Public Repos",
                    value: "\(summary.publicRepositories)",
                    icon: "folder",
                    color: .blue
                )
                
                StatCardView(
                    title: "Total Stars",
                    value: "\(summary.totalStars)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                StatCardView(
                    title: "Open Issues",
                    value: "\(summary.totalOpenIssues)",
                    icon: "exclamationmark.circle",
                    color: .red
                )
                
                StatCardView(
                    title: "Open PRs",
                    value: "\(summary.totalOpenPullRequests)",
                    icon: "arrow.triangle.pull",
                    color: .green
                )
            }
        }
    }
    
    // MARK: - Repository Stats View
    
    private func repositoryStatsView(_ summary: UserSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Repository Activity")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(summary.totalRepositories) total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                StatCardView(
                    title: "Followers",
                    value: "\(summary.user.followers)",
                    icon: "person.2.fill",
                    color: .purple
                )
                
                StatCardView(
                    title: "Following",
                    value: "\(summary.user.following)",
                    icon: "person.badge.plus",
                    color: .indigo
                )
            }
        }
    }
    
    // MARK: - Recent Repositories View
    
    private func recentRepositoriesView(_ summary: UserSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Repositories")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 8) {
                ForEach(Array(summary.repositoryStats.prefix(5))) { stat in
                    RepositoryCardView(repositoryStats: stat)
                }
                
                if summary.repositoryStats.count > 5 {
                    Text("and \(summary.repositoryStats.count - 5) more repositories...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            }
        }
    }
    
    // MARK: - Progressive My Repositories Section
    
    private var myRepositoriesSection: some View {
        ProgressiveRepositorySection(
            title: "My Repositories",
            icon: "person.crop.circle",
            iconColor: .blue,
            repositoryStats: myRepositoryStats,
            userLogin: userInfo?.login,
            isLoading: isLoadingMyRepos
        )
    }
    
    // MARK: - Progressive Other Repositories Section
    
    private var otherRepositoriesSection: some View {
        ProgressiveRepositorySection(
            title: "Other Repositories",
            icon: "globe",
            iconColor: .purple,
            repositoryStats: otherRepositoryStats,
            userLogin: userInfo?.login,
            isLoading: isLoadingOtherRepos,
            isOtherRepos: true
        )
    }
    
    // MARK: - Progressive Social Stats View
    
    private var socialStatsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.2")
                    .font(.title2)
                    .foregroundColor(.indigo)
                
                Text("Social")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                if let userInfo = userInfo {
                    StatCardView(
                        title: "Followers",
                        value: "\(userInfo.followers)",
                        icon: "person.2.fill",
                        color: .purple
                    )
                    
                    StatCardView(
                        title: "Following",
                        value: "\(userInfo.following)",
                        icon: "person.badge.plus",
                        color: .indigo
                    )
                } else {
                    SkeletonStatCardView(title: "Followers", icon: "person.2.fill", color: .purple)
                    SkeletonStatCardView(title: "Following", icon: "person.badge.plus", color: .indigo)
                }
            }
        }
    }
    
    // MARK: - Progressive Data Loading
    
    private func loadGitHubDataProgressively() async {
        // Cancel any existing loading task
        loadingTask?.cancel()
        
        // Create new loading task
        loadingTask = Task {
            await performDataLoading()
        }
        
        await loadingTask?.value
    }
    
    private func performDataLoading() async {
        guard let token = authViewModel.loadOAuthToken() else {
            await MainActor.run {
                self.errorMessage = "No OAuth token found. Please sign in again."
                self.isLoadingUserInfo = false
                self.isLoadingMyRepos = false
                self.isLoadingOtherRepos = false
            }
            return
        }
        
        // Check for cancellation
        guard !Task.isCancelled else {
            print("💫 Task was cancelled before starting")
            return
        }
        
        // Reset states
        await MainActor.run {
            self.errorMessage = nil
            self.isLoadingUserInfo = true
            self.isLoadingMyRepos = true
            self.isLoadingOtherRepos = true
            self.userInfo = nil
            self.myRepositoryStats = []
            self.otherRepositoryStats = []
        }
        
        // Start concurrent loading
        async let userInfoTask = loadUserInfo(token: token)
        async let repositoryStatsTask = loadAllRepositoryStats(token: token)
        
        // Load user info first (fastest)
        await userInfoTask
        
        // Check for cancellation before loading repo stats
        guard !Task.isCancelled else {
            print("💫 Task was cancelled after user info")
            return
        }
        
        // Load repository stats
        await repositoryStatsTask
    }
    
    private func loadUserInfo(token: String) async {
        // Check for cancellation
        guard !Task.isCancelled else {
            await MainActor.run {
                self.isLoadingUserInfo = false
            }
            return
        }
        
        do {
            let user = try await gitHubService.fetchUserInfo(oauthToken: token)
            
            // Check for cancellation before updating UI
            guard !Task.isCancelled else {
                print("💫 User info task was cancelled")
                return
            }
            
            await MainActor.run {
                self.userInfo = user
                self.isLoadingUserInfo = false
                print("✅ User info loaded")
            }
        } catch {
            // Only show error if not cancelled
            guard !Task.isCancelled else {
                print("💫 User info task was cancelled during error handling")
                return
            }
            
            await MainActor.run {
                self.isLoadingUserInfo = false
                
                // Check if it's a cancellation error
                let errorString = error.localizedDescription.lowercased()
                if errorString.contains("cancelled") || errorString.contains("canceled") {
                    print("💫 User info request was cancelled")
                    return
                }
                
                if self.errorMessage == nil {
                    self.errorMessage = "Failed to load user info: \(error.localizedDescription)"
                }
                print("❌ Error loading user info: \(error)")
            }
        }
    }
    
    private func loadAllRepositoryStats(token: String) async {
        // Check for cancellation
        guard !Task.isCancelled else {
            await MainActor.run {
                self.isLoadingMyRepos = false
                self.isLoadingOtherRepos = false
            }
            return
        }
        
        do {
            let allStats = try await gitHubService.fetchAllRepositoryStats(oauthToken: token)
            
            // Check for cancellation before updating UI
            guard !Task.isCancelled else {
                print("💫 Repository stats task was cancelled")
                return
            }
            
            await MainActor.run {
                guard let userLogin = self.userInfo?.login else {
                    self.isLoadingMyRepos = false
                    self.isLoadingOtherRepos = false
                    return
                }
                
                self.myRepositoryStats = allStats.filter { $0.repository.owner.login == userLogin }
                self.otherRepositoryStats = allStats.filter { $0.repository.owner.login != userLogin }
                
                self.isLoadingMyRepos = false
                self.isLoadingOtherRepos = false
                
                print("✅ Repository stats loaded - My: \(self.myRepositoryStats.count), Other: \(self.otherRepositoryStats.count)")
            }
        } catch {
            // Only show error if not cancelled
            guard !Task.isCancelled else {
                print("💫 Repository stats task was cancelled during error handling")
                return
            }
            
            await MainActor.run {
                self.isLoadingMyRepos = false
                self.isLoadingOtherRepos = false
                
                // Check if it's a cancellation error
                let errorString = error.localizedDescription.lowercased()
                if errorString.contains("cancelled") || errorString.contains("canceled") {
                    print("💫 Repository stats request was cancelled")
                    return
                }
                
                if self.errorMessage == nil {
                    self.errorMessage = "Failed to load repositories: \(error.localizedDescription)"
                }
                print("❌ Error loading repository stats: \(error)")
            }
        }
    }
    
    // MARK: - Legacy Methods (to be removed)
    
    private func myRepositoriesSection(_ summary: UserSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.crop.circle")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("My Repositories")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(summary.myRepositoryStats.count) repos")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Stats Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                StatCardView(
                    title: "Public Repos",
                    value: "\(summary.myPublicRepositories)",
                    icon: "folder",
                    color: .blue
                )
                
                StatCardView(
                    title: "Private Repos",
                    value: "\(summary.myPrivateRepositories)",
                    icon: "lock.fill",
                    color: .orange
                )
                
                StatCardView(
                    title: "Stars",
                    value: "\(summary.myRepositoryStars)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                StatCardView(
                    title: "Open Issues",
                    value: "\(summary.myOpenIssues)",
                    icon: "exclamationmark.circle",
                    color: .red
                )
                
                StatCardView(
                    title: "Open PRs",
                    value: "\(summary.myOpenPullRequests)",
                    icon: "arrow.triangle.pull",
                    color: .green
                )
            }
            
            // Recent My Repositories
            if !summary.myRepositoryStats.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    LazyVStack(spacing: 8) {
                        ForEach(Array(summary.myRepositoryStats.prefix(3))) { stat in
                            RepositoryCardView(repositoryStats: stat)
                        }
                        
                        if summary.myRepositoryStats.count > 3 {
                            Text("and \(summary.myRepositoryStats.count - 3) more...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Other Repositories Section
    
    private func otherRepositoriesSection(_ summary: UserSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "globe")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text("Other Repositories")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(summary.otherRepositoryStats.count) repos")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Stats Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                StatCardView(
                    title: "Public Repos",
                    value: "\(summary.otherPublicRepositories)",
                    icon: "folder",
                    color: .blue
                )
                
                StatCardView(
                    title: "Private Repos",
                    value: "\(summary.otherPrivateRepositories)",
                    icon: "lock.fill",
                    color: .orange
                )
                
                StatCardView(
                    title: "Stars",
                    value: "\(summary.otherRepositoryStars)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                StatCardView(
                    title: "Open Issues",
                    value: "\(summary.otherOpenIssues)",
                    icon: "exclamationmark.circle",
                    color: .red
                )
                
                StatCardView(
                    title: "Open PRs",
                    value: "\(summary.otherOpenPullRequests)",
                    icon: "arrow.triangle.pull",
                    color: .green
                )
            }
            
            // Recent Other Repositories
            if !summary.otherRepositoryStats.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Contributions")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    LazyVStack(spacing: 8) {
                        ForEach(Array(summary.otherRepositoryStats.prefix(3))) { stat in
                            RepositoryCardView(repositoryStats: stat)
                        }
                        
                        if summary.otherRepositoryStats.count > 3 {
                            Text("and \(summary.otherRepositoryStats.count - 3) more...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Social Stats View
    
    private func socialStatsView(_ summary: UserSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.2")
                    .font(.title2)
                    .foregroundColor(.indigo)
                
                Text("Social")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                StatCardView(
                    title: "Followers",
                    value: "\(summary.user.followers)",
                    icon: "person.2.fill",
                    color: .purple
                )
                
                StatCardView(
                    title: "Following",
                    value: "\(summary.user.following)",
                    icon: "person.badge.plus",
                    color: .indigo
                )
            }
        }
    }
    
}

// MARK: - Custom UI Components

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

// MARK: - Progressive Loading Components

struct ProgressiveRepositorySection: View {
    let title: String
    let icon: String
    let iconColor: Color
    let repositoryStats: [RepositoryStats]
    let userLogin: String?
    let isLoading: Bool
    let isOtherRepos: Bool
    
    init(title: String, icon: String, iconColor: Color, repositoryStats: [RepositoryStats], userLogin: String?, isLoading: Bool, isOtherRepos: Bool = false) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.repositoryStats = repositoryStats
        self.userLogin = userLogin
        self.isLoading = isLoading
        self.isOtherRepos = isOtherRepos
    }
    
    private var myRepositoryStats: [RepositoryStats] {
        guard let userLogin = userLogin else { return [] }
        return repositoryStats.filter { $0.repository.owner.login == userLogin }
    }
    
    private var otherRepositoryStats: [RepositoryStats] {
        guard let userLogin = userLogin else { return repositoryStats }
        return repositoryStats.filter { $0.repository.owner.login != userLogin }
    }
    
    private var relevantStats: [RepositoryStats] {
        isOtherRepos ? otherRepositoryStats : myRepositoryStats
    }
    
    private var publicRepos: Int {
        relevantStats.filter { !$0.repository.isPrivate }.count
    }
    
    private var privateRepos: Int {
        relevantStats.filter { $0.repository.isPrivate }.count
    }
    
    private var stars: Int {
        relevantStats.reduce(0) { $0 + $1.repository.stargazersCount }
    }
    
    private var openIssues: Int {
        relevantStats.reduce(0) { $0 + $1.openIssues }
    }
    
    private var openPRs: Int {
        relevantStats.reduce(0) { $0 + $1.openPullRequests }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
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
                } else {
                    Text("\(relevantStats.count) repos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Stats Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                if isLoading {
                    SkeletonStatCardView(title: "Public Repos", icon: "folder", color: .blue)
                    SkeletonStatCardView(title: "Private Repos", icon: "lock.fill", color: .orange)
                    SkeletonStatCardView(title: "Stars", icon: "star.fill", color: .yellow)
                    SkeletonStatCardView(title: "Open Issues", icon: "exclamationmark.circle", color: .red)
                    SkeletonStatCardView(title: "Open PRs", icon: "arrow.triangle.pull", color: .green)
                } else {
                    StatCardView(
                        title: "Public Repos",
                        value: "\(publicRepos)",
                        icon: "folder",
                        color: .blue
                    )
                    
                    StatCardView(
                        title: "Private Repos",
                        value: "\(privateRepos)",
                        icon: "lock.fill",
                        color: .orange
                    )
                    
                    StatCardView(
                        title: "Stars",
                        value: "\(stars)",
                        icon: "star.fill",
                        color: .yellow
                    )
                    
                    StatCardView(
                        title: "Open Issues",
                        value: "\(openIssues)",
                        icon: "exclamationmark.circle",
                        color: .red
                    )
                    
                    StatCardView(
                        title: "Open PRs",
                        value: "\(openPRs)",
                        icon: "arrow.triangle.pull",
                        color: .green
                    )
                }
            }
            
            // Recent Repositories
            if isLoading || !relevantStats.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(isOtherRepos ? "Recent Contributions" : "Recent")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    if isLoading {
                        LazyVStack(spacing: 8) {
                            ForEach(0..<3, id: \.self) { _ in
                                SkeletonRepositoryCardView()
                            }
                        }
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(Array(relevantStats.prefix(3))) { stat in
                                RepositoryCardView(repositoryStats: stat)
                            }
                            
                            if relevantStats.count > 3 {
                                Text("and \(relevantStats.count - 3) more...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                    }
                }
            }
        }
    }
}

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

// MARK: - User Profile Card Component

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
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
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
            
            // Bio skeleton
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 14)
                    .redacted(reason: .placeholder)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 14)
                    .redacted(reason: .placeholder)
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

// MARK: - Extensions

extension RepositoryStats: Identifiable {
    var id: Int { repository.id }
}

#Preview {
    DashboardView()
}

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
