//
//  AnvilApp.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 24/8/25.
//

import SwiftUI

@main
struct AnvilApp: App {
    var body: some Scene {
        WindowGroup {
            TabView{
                DashboardView()
                    .tabItem {
                        Label("Home", systemImage: "square.and.arrow.up")
                    }
                CalculatorView()
                    .tabItem {
                        Label("Calculator", systemImage: "gear")
                    }
            }
        }
    }
}
