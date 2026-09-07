//
//  GitHubFetches.swift
//  Anvil
//
//  GitHub API service for fetching user data
//

import Foundation

// MARK: - Data Models

struct GitHubRepository: Codable, Identifiable {
    let id: Int
    let name: String
    let fullName: String
    let isPrivate: Bool
    let stargazersCount: Int
    let openIssuesCount: Int
    let forksCount: Int
    let language: String?
    let description: String?
    let htmlUrl: String
    let createdAt: String
    let updatedAt: String
    let owner: RepositoryOwner
    let isFork: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description, language, owner
        case fullName = "full_name"
        case isPrivate = "private"
        case stargazersCount = "stargazers_count"
        case openIssuesCount = "open_issues_count"
        case forksCount = "forks_count"
        case htmlUrl = "html_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isFork = "fork"
    }
}

struct RepositoryOwner: Codable {
    let id: Int
    let login: String
    let avatarUrl: String
    
    private enum CodingKeys: String, CodingKey {
        case id, login
        case avatarUrl = "avatar_url"
    }
}

struct GitHubUser: Codable {
    let id: Int
    let login: String
    let name: String?
    let publicRepos: Int
    let publicGists: Int
    let followers: Int
    let following: Int
    let avatarUrl: String
    let bio: String?
    let location: String?
    let company: String?
    let blog: String?
    let email: String?
    let twitterUsername: String?
    let hireable: Bool?
    let createdAt: String
    let updatedAt: String
    
    private enum CodingKeys: String, CodingKey {
        case id, login, name, followers, following, bio, location, company, blog, email, hireable
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
        case avatarUrl = "avatar_url"
        case twitterUsername = "twitter_username"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct GitHubIssue: Codable, Identifiable {
    let id: Int
    let number: Int
    let title: String
    let state: String
    let createdAt: String
    let updatedAt: String
    let htmlUrl: String
    
    private enum CodingKeys: String, CodingKey {
        case id, number, title, state
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case htmlUrl = "html_url"
    }
}

struct GitHubPullRequest: Codable, Identifiable {
    let id: Int
    let number: Int
    let title: String
    let state: String
    let createdAt: String
    let updatedAt: String
    let htmlUrl: String
    
    private enum CodingKeys: String, CodingKey {
        case id, number, title, state
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case htmlUrl = "html_url"
    }
}

struct LanguageStats {
    let name: String
    let percentage: Double
    let bytes: Int
}

struct RepositoryStats {
    let repository: GitHubRepository
    let openIssues: Int
    let openPullRequests: Int
    let languageStats: [LanguageStats]
}

struct UserContributions: Codable {
    let totalContributions: Int
    let weeks: [WeekContributions]
    
    private enum CodingKeys: String, CodingKey {
        case totalContributions = "total"
        case weeks
    }
}

struct WeekContributions: Codable {
    let week: Int
    let days: [DayContributions]
}

struct DayContributions: Codable {
    let date: String
    let count: Int
}

// MARK: - GitHub API Service

class GitHubFetches {
    private let baseURL = "https://api.github.com"
    
    // MARK: - Error Handling
    
    enum GitHubError: Error, LocalizedError {
        case invalidURL
        case noData
        case invalidToken
        case networkError(String)
        case decodingError(String)
        case apiError(Int, String)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .noData:
                return "No data received"
            case .invalidToken:
                return "Invalid or expired OAuth token"
            case .networkError(let message):
                return "Network error: \(message)"
            case .decodingError(let message):
                return "Data parsing error: \(message)"
            case .apiError(let code, let message):
                return "API error (\(code)): \(message)"
            }
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func createRequest(for endpoint: String, oauthToken: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw GitHubError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(oauthToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("Anvil iOS App", forHTTPHeaderField: "User-Agent")
        
        return request
    }
    
    private func performRequest<T: Codable>(_ request: URLRequest, responseType: T.Type) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw GitHubError.networkError("Invalid response type")
            }
            
            // Check for API errors
            if httpResponse.statusCode == 401 {
                throw GitHubError.invalidToken
            } else if httpResponse.statusCode >= 400 {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw GitHubError.apiError(httpResponse.statusCode, errorMessage)
            }
            
            // Decode the response
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(responseType, from: data)
            } catch {
                throw GitHubError.decodingError(error.localizedDescription)
            }
            
        } catch let error as GitHubError {
            throw error
        } catch {
            throw GitHubError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Public API Methods
    
    /// Fetches the authenticated user's basic information
    func fetchUserInfo(oauthToken: String) async throws -> GitHubUser {
        let request = try createRequest(for: "user", oauthToken: oauthToken)
        return try await performRequest(request, responseType: GitHubUser.self)
    }
    
    /// Fetches the user's number of public repositories
    func fetchPublicRepositoryCount(oauthToken: String) async throws -> Int {
        let user = try await fetchUserInfo(oauthToken: oauthToken)
        return user.publicRepos
    }
    
    /// Fetches all repositories for the authenticated user
    func fetchAllRepositories(oauthToken: String) async throws -> [GitHubRepository] {
        var allRepositories: [GitHubRepository] = []
        var page = 1
        let perPage = 100
        
        while true {
            let request = try createRequest(for: "user/repos?page=\(page)&per_page=\(perPage)&sort=updated", oauthToken: oauthToken)
            let repositories: [GitHubRepository] = try await performRequest(request, responseType: [GitHubRepository].self)
            
            if repositories.isEmpty {
                break
            }
            
            allRepositories.append(contentsOf: repositories)
            page += 1
        }
        
        return allRepositories
    }
    
    /// Fetches only public repositories for the authenticated user
    func fetchPublicRepositories(oauthToken: String) async throws -> [GitHubRepository] {
        let allRepos = try await fetchAllRepositories(oauthToken: oauthToken)
        return allRepos.filter { !$0.isPrivate }
    }
    
    /// Calculates total number of stars across all user repositories
    func fetchTotalStarsCount(oauthToken: String) async throws -> Int {
        let repositories = try await fetchAllRepositories(oauthToken: oauthToken)
        return repositories.reduce(0) { $0 + $1.stargazersCount }
    }
    
    /// Calculates total number of stars across public repositories only
    func fetchPublicRepositoriesStarsCount(oauthToken: String) async throws -> Int {
        let publicRepositories = try await fetchPublicRepositories(oauthToken: oauthToken)
        return publicRepositories.reduce(0) { $0 + $1.stargazersCount }
    }
    
    /// Fetches open issues for a specific repository
    func fetchOpenIssues(for repository: GitHubRepository, oauthToken: String) async throws -> [GitHubIssue] {
        let endpoint = "repos/\(repository.fullName)/issues?state=open&per_page=100"
        let request = try createRequest(for: endpoint, oauthToken: oauthToken)
        return try await performRequest(request, responseType: [GitHubIssue].self)
    }
    
    /// Fetches the count of open issues for a specific repository
    func fetchOpenIssuesCount(for repository: GitHubRepository, oauthToken: String) async throws -> Int {
        let issues = try await fetchOpenIssues(for: repository, oauthToken: oauthToken)
        // Filter out pull requests (GitHub API includes PRs in issues endpoint)
        return issues.filter { !$0.htmlUrl.contains("/pull/") }.count
    }
    
    /// Fetches open pull requests for a specific repository
    func fetchOpenPullRequests(for repository: GitHubRepository, oauthToken: String) async throws -> [GitHubPullRequest] {
        let endpoint = "repos/\(repository.fullName)/pulls?state=open&per_page=100"
        let request = try createRequest(for: endpoint, oauthToken: oauthToken)
        return try await performRequest(request, responseType: [GitHubPullRequest].self)
    }
    
    /// Fetches the count of open pull requests for a specific repository
    func fetchOpenPullRequestsCount(for repository: GitHubRepository, oauthToken: String) async throws -> Int {
        let pullRequests = try await fetchOpenPullRequests(for: repository, oauthToken: oauthToken)
        return pullRequests.count
    }
    
    /// Fetches language statistics for a specific repository
    func fetchLanguageStats(for repository: GitHubRepository, oauthToken: String) async throws -> [LanguageStats] {
        let endpoint = "repos/\(repository.fullName)/languages"
        let request = try createRequest(for: endpoint, oauthToken: oauthToken)
        
        do {
            let languageBytes: [String: Int] = try await performRequest(request, responseType: [String: Int].self)
            
            // If no languages found, return empty array
            guard !languageBytes.isEmpty else {
                return []
            }
            
            // Calculate total bytes
            let totalBytes = languageBytes.values.reduce(0, +)
            
            // Convert to LanguageStats with percentages
            let languageStats = languageBytes.map { (language, bytes) in
                let percentage = totalBytes > 0 ? (Double(bytes) / Double(totalBytes)) * 100.0 : 0.0
                return LanguageStats(name: language, percentage: percentage, bytes: bytes)
            }.sorted { $0.percentage > $1.percentage } // Sort by percentage descending
            
            return languageStats
        } catch {
            // If language endpoint fails (e.g. empty repo), return empty array
            return []
        }
    }
    
    /// Fetches repository stats (repository info + open issues + open PRs + language stats) for a specific repository
    func fetchRepositoryStats(for repository: GitHubRepository, oauthToken: String) async throws -> RepositoryStats {
        async let openIssuesCount = fetchOpenIssuesCount(for: repository, oauthToken: oauthToken)
        async let openPRsCount = fetchOpenPullRequestsCount(for: repository, oauthToken: oauthToken)
        async let languageStats = fetchLanguageStats(for: repository, oauthToken: oauthToken)
        
        let issues = try await openIssuesCount
        let prs = try await openPRsCount
        let languages = try await languageStats
        
        return RepositoryStats(
            repository: repository,
            openIssues: issues,
            openPullRequests: prs,
            languageStats: languages
        )
    }
    
    /// Fetches complete repository stats for all user repositories
    func fetchAllRepositoryStats(oauthToken: String) async throws -> [RepositoryStats] {
        let repositories = try await fetchAllRepositories(oauthToken: oauthToken)
        
        var repositoryStats: [RepositoryStats] = []
        
        // Process repositories in batches to avoid overwhelming the API
        let batchSize = 5
        for i in stride(from: 0, to: repositories.count, by: batchSize) {
            let endIndex = min(i + batchSize, repositories.count)
            let batch = Array(repositories[i..<endIndex])
            
            let batchStats = try await withThrowingTaskGroup(of: RepositoryStats.self) { group in
                for repository in batch {
                    group.addTask {
                        try await self.fetchRepositoryStats(for: repository, oauthToken: oauthToken)
                    }
                }
                
                var results: [RepositoryStats] = []
                for try await stat in group {
                    results.append(stat)
                }
                return results
            }
            
            repositoryStats.append(contentsOf: batchStats)
            
            // Small delay between batches to be respectful to GitHub's API
            if endIndex < repositories.count {
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            }
        }
        
        return repositoryStats
    }
    
    /// Fetches a comprehensive summary of user's GitHub activity
    func fetchUserSummary(oauthToken: String) async throws -> UserSummary {
        async let userInfo = fetchUserInfo(oauthToken: oauthToken)
        async let totalStars = fetchTotalStarsCount(oauthToken: oauthToken)
        async let repositoryStats = fetchAllRepositoryStats(oauthToken: oauthToken)
        
        let user = try await userInfo
        let stars = try await totalStars
        let stats = try await repositoryStats
        
        let publicRepos = stats.filter { !$0.repository.isPrivate }
        
        return UserSummary(
            user: user,
            totalRepositories: stats.count,
            publicRepositories: publicRepos.count,
            totalStars: stars,
            repositoryStats: stats
        )
    }
}

// MARK: - Summary Data Model

struct UserSummary {
    let user: GitHubUser
    let totalRepositories: Int
    let publicRepositories: Int
    let totalStars: Int
    let repositoryStats: [RepositoryStats]
    
    // My Repositories (owned by the user)
    var myRepositoryStats: [RepositoryStats] {
        repositoryStats.filter { $0.repository.owner.login == user.login }
    }
    
    // Other Repositories (contributed to but not owned)
    var otherRepositoryStats: [RepositoryStats] {
        repositoryStats.filter { $0.repository.owner.login != user.login }
    }
    
    // My Repository Stats
    var myPublicRepositories: Int {
        myRepositoryStats.filter { !$0.repository.isPrivate }.count
    }
    
    var myPrivateRepositories: Int {
        myRepositoryStats.filter { $0.repository.isPrivate }.count
    }
    
    var myRepositoryStars: Int {
        myRepositoryStats.reduce(0) { $0 + $1.repository.stargazersCount }
    }
    
    var myOpenIssues: Int {
        myRepositoryStats.reduce(0) { $0 + $1.openIssues }
    }
    
    var myOpenPullRequests: Int {
        myRepositoryStats.reduce(0) { $0 + $1.openPullRequests }
    }
    
    // Other Repository Stats
    var otherPublicRepositories: Int {
        otherRepositoryStats.filter { !$0.repository.isPrivate }.count
    }
    
    var otherPrivateRepositories: Int {
        otherRepositoryStats.filter { $0.repository.isPrivate }.count
    }
    
    var otherRepositoryStars: Int {
        otherRepositoryStats.reduce(0) { $0 + $1.repository.stargazersCount }
    }
    
    var otherOpenIssues: Int {
        otherRepositoryStats.reduce(0) { $0 + $1.openIssues }
    }
    
    var otherOpenPullRequests: Int {
        otherRepositoryStats.reduce(0) { $0 + $1.openPullRequests }
    }
    
    // Legacy computed properties (for backward compatibility)
    var totalOpenIssues: Int {
        repositoryStats.reduce(0) { $0 + $1.openIssues }
    }
    
    var totalOpenPullRequests: Int {
        repositoryStats.reduce(0) { $0 + $1.openPullRequests }
    }
}

// MARK: - Convenience Extensions

extension GitHubFetches {
    /// Convenience method to get basic stats quickly
    func fetchBasicStats(oauthToken: String) async throws -> (publicRepos: Int, totalStars: Int) {
        async let publicReposCount = fetchPublicRepositoryCount(oauthToken: oauthToken)
        async let totalStarsCount = fetchTotalStarsCount(oauthToken: oauthToken)
        
        let repos = try await publicReposCount
        let stars = try await totalStarsCount
        
        return (publicRepos: repos, totalStars: stars)
    }
}
