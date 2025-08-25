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
        Text("Hello, World!")
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
    DashboardView()
}
