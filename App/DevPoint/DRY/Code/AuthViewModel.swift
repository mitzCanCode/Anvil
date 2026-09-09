//
//  AuthViewModel.swift
//  DevPoint
//

import Foundation
import Combine
import Security

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var user: GitHubUser?
    @Published private(set) var hasAccessToken: Bool
    @Published var isLoading = false
    @Published var errorMessage: String?

    private static let accessTokenKey = "githubAccessToken"

    init() {
        hasAccessToken = Self.loadFromKeychain(forKey: Self.accessTokenKey) != nil
    }

    func saveAccessToken(_ token: String) async {
        let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedToken.isEmpty else {
            errorMessage = "Enter a GitHub personal access token."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let gitHubUser = try await GitHubFetches().fetchUserInfo(oauthToken: trimmedToken)
            try Self.saveToKeychain(trimmedToken, forKey: Self.accessTokenKey)
            user = gitHubUser
            hasAccessToken = true
        } catch {
            errorMessage = "Could not validate this GitHub token: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func refreshUser() async {
        guard let token = loadOAuthToken() else { return }

        do {
            user = try await GitHubFetches().fetchUserInfo(oauthToken: token)
        } catch {
            user = nil
        }
    }

    func signOut() {
        Self.deleteFromKeychain(forKey: Self.accessTokenKey)
        user = nil
        hasAccessToken = false
        errorMessage = nil
    }

    func loadOAuthToken() -> String? {
        Self.loadFromKeychain(forKey: Self.accessTokenKey)
    }

    private static func saveToKeychain(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(
                domain: NSOSStatusErrorDomain,
                code: Int(status),
                userInfo: [NSLocalizedDescriptionKey: "The token could not be saved securely on this device."]
            )
        }
    }

    private static func loadFromKeychain(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    private static func deleteFromKeychain(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
