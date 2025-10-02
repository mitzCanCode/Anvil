//
//  DashboardHelperViews.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 27/8/25.
//

import SwiftUI

// MARK: - Error View

struct ErrorView: View {
    let message: String
    let onRetry: () async -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
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
                    await onRetry()
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 50)
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple.opacity(0.3), lineWidth: 7)
            )
            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
        }
        .padding()
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    Color.purple.opacity(0.3),
                    lineWidth: 8
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}
