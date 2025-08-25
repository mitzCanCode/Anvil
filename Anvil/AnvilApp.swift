//
//  AnvilApp.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 24/8/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import AuthenticationServices

// MARK: - App Delegate for Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return Auth.auth().canHandle(url)
    }
}

@main
struct AnvilApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if let user = authVM.user {
                TabView{
                    
                    DashboardView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    
                    CalculatorView()
                        .tabItem {
                            Label("Calculator", systemImage: "plus.forwardslash.minus")
                        }
                    
                    MoreView(authViewModel: authVM)
                        .tabItem {
                            Label("More", systemImage: "ellipsis.circle")
                        }
                }
                
            } else {
                SignInView(authViewModel: authVM)
            }
        }
    }
}
