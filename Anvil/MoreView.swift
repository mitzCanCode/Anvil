//
//  MoreView.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 25/8/25.
//

import SwiftUI

struct MoreView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            List {
                // User Profile Section
                Section {
                    HStack(spacing: 16) {
                        // Profile Image Placeholder
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authViewModel.user?.displayName ?? "GitHub User")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            if let email = authViewModel.user?.email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("User ID: \(authViewModel.user?.uid.prefix(8) ?? "Unknown")...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // App Settings Section
                Section("Settings") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("About")
                        Spacer()
                        Text("Version 1.0")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        Text("Help & Support")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    
                    HStack {
                        Image(systemName: "star.circle")
                            .foregroundColor(.yellow)
                            .frame(width: 24)
                        Text("Rate App")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                // Account Section
                Section("Account") {
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("Sign Out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                
                // Footer Section
                Section {
                    VStack(spacing: 12) {
                        Text("Anvil")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("Built with SwiftUI and Firebase")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("© 2025 mitzCanCode")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
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
            .ignoresSafeArea()
        )
    }
}

#Preview {
    MoreView(authViewModel: AuthViewModel())
}
