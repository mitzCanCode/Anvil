//
//  DashboardLoadingState.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 27/8/25.
//

import Foundation

@MainActor
class DashboardLoadingState: ObservableObject {
    @Published var isLoading = false
    @Published var userInfo: GitHubUser?
    @Published var repositories: [RepositoryStats] = []
    @Published var errorMessage: String?
    
    private var loadingTask: Task<Void, Never>?
    private let gitHubService = GitHubFetches()
    
    var myRepositories: [RepositoryStats] {
        guard let userLogin = userInfo?.login else { return [] }
        return repositories.filter { $0.repository.owner.login == userLogin }
    }
    
    var otherRepositories: [RepositoryStats] {
        guard let userLogin = userInfo?.login else { return repositories }
        return repositories.filter { $0.repository.owner.login != userLogin }
    }
    
    func loadData(with token: String) async {
        // Cancel any existing loading task
        loadingTask?.cancel()
        
        // Create new loading task
        loadingTask = Task {
            await performDataLoading(token: token)
        }
        
        await loadingTask?.value
    }
    
    private func performDataLoading(token: String) async {
        // Check for cancellation
        guard !Task.isCancelled else { return }
        
        // Reset state
        isLoading = true
        errorMessage = nil
        userInfo = nil
        repositories = []
        
        do {
            // Load user info and repositories concurrently
            async let userTask = gitHubService.fetchUserInfo(oauthToken: token)
            async let reposTask = gitHubService.fetchAllRepositoryStats(oauthToken: token)
            
            // Wait for both to complete
            let (user, repos) = try await (userTask, reposTask)
            
            // Check for cancellation before updating
            guard !Task.isCancelled else { return }
            
            // Update state
            userInfo = user
            repositories = repos
            isLoading = false
            
        } catch {
            guard !Task.isCancelled else { return }
            
            let errorString = error.localizedDescription.lowercased()
            if !errorString.contains("cancelled") && !errorString.contains("canceled") {
                errorMessage = "Failed to load GitHub data: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
    
    func refresh(with token: String) async {
        await loadData(with: token)
    }
    
    func cancelLoading() {
        loadingTask?.cancel()
        isLoading = false
    }
}
