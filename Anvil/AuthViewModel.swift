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
        // Check if user is already signed in
        self.user = Auth.auth().currentUser
        
        // Listen for auth state changes
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
                isLoading = true
                errorMessage = nil
                
                let provider = OAuthProvider(providerID: "github.com")
                provider.scopes = ["user:email"]
                provider.customParameters = ["allow_signup": "true"]
                
                print("🌐 Getting credentials from OAuth provider...")
                
                // Get credentials from the provider first
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
                
                print("🔐 Got credentials, signing in to Firebase...")
                
                // Then sign in with the credential
                let authResult = try await Auth.auth().signIn(with: credential)
                
                print("✅ Firebase Auth succeeded!")
                print("👤 User ID: \(authResult.user.uid)")
                print("👤 Email: \(authResult.user.email ?? "No email")")
                print("👤 Display Name: \(authResult.user.displayName ?? "No name")")
                
                self.user = authResult.user
                self.isLoading = false
                
            } catch {
                print("❌ GitHub sign-in failed: \(error.localizedDescription)")
                print("❌ Full error: \(error)")
                
                self.errorMessage = "GitHub sign-in failed: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            print("User signed out successfully")
        } catch let signOutError {
            self.errorMessage = "Sign out failed: \(signOutError.localizedDescription)"
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}
