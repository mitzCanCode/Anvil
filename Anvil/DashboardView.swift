//
//  DashboardView.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 24/8/25.
//

import SwiftUI

struct DashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    Text("Welcome to Anvil")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Your GitHub activity at a glance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
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

        }

    }
}

#Preview {
    DashboardView()
}
