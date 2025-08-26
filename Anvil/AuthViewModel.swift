//
//  AuthViewModel.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 25/8/25.
//

import FirebaseAuth
import AuthenticationServices
import SwiftUI

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
                provider.scopes = ["user:email"]
                
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
        } catch let signOutError {
            self.errorMessage = "Sign out failed: \(signOutError.localizedDescription)"
        }
    }
}
