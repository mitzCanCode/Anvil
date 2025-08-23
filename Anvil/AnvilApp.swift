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
                ContentView()
                    .tabItem {
                        Label("Content", systemImage: "square.and.arrow.up")
                    }
                CalculatorView()
                    .tabItem {
                        Label("Calculator", systemImage: "gear")
                    }
            }
        }
    }
}
