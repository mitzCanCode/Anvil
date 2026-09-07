//
//  AuthViewModel.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 25/8/25.
//

import FirebaseAuth
import AuthenticationServices
import SwiftUI
import Security

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        self.user = Auth.auth().currentUser

        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
            }
        }
    }

    @MainActor
    func signInWithGitHub() {
        print("🔄 Starting GitHub sign-in process...")
        
        Task {
            do {
                let provider = OAuthProvider(providerID: "github.com")
                provider.scopes = ["read:user", "repo"]
                
                let credential = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthCredential, Error>) in
                    provider.getCredentialWith(nil) { credential, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let credential = credential {
                            continuation.resume(returning: credential)
                        } else {
                            continuation.resume(throwing: NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No credential received"]))
                        }
                    }
                }
                
                let authResult = try await Auth.auth().signIn(with: credential)
                if let oauthCredential = authResult.credential as? OAuthCredential {
                    let accessToken = oauthCredential.accessToken

                    print("✅ Access Token: \(accessToken ?? "nil")")

                    if let token = accessToken {
                        saveToKeychain(token, forKey: "githubAccessToken")
                    }
                }
                self.user = authResult.user
                self.isLoading = false
                
            } catch {
                self.errorMessage = "GitHub sign-in failed: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            deleteFromKeychain(forKey: "githubAccessToken")
        } catch let signOutError {
            self.errorMessage = "Sign out failed: \(signOutError.localizedDescription)"
        }
    }
    
    private func saveToKeychain(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func loadFromKeychain(forKey key: String) -> String? {
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
    
    private func deleteFromKeychain(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
    func loadOAuthToken() -> String? {
        return loadFromKeychain(forKey: "githubAccessToken")
    }
}
