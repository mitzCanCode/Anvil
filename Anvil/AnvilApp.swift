//
//  AnvilApp.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 24/8/25.
//

import SwiftUI
import UIKit
import Firebase
import FirebaseAuth
import AuthenticationServices
import SwiftData

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
    
    private let modelContainer: ModelContainer

    init() {
        // Must register before the app finishes launching.
        CheckpointMonitoringService.registerBackgroundTasks()

        let container = Self.makeModelContainer()
        modelContainer = container

        let monitoring = CheckpointMonitoringService.shared
        monitoring.configure(modelContainer: container)
        monitoring.start()
    }
    private static func makeModelContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: Checkpoint.self)
        } catch {
            fatalError("Unable to create checkpoint model container: \(error)")
        }
    }

    
    var body: some Scene {
        WindowGroup {
            if let user = authVM.user {
                TabView {
                    DashboardView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    
                    CheckpointsView()
                        .tabItem {
                            Label("Websites", systemImage: "network")
                        }
                    
                    PaletteGeneratorView()
                        .tabItem {
                            Label("Palette", systemImage: "paintbrush.fill")
                        }
                    //                    RegexGeneratorView()
                    //                        .tabItem {
                    //                            Label("Regex", systemImage: "curlybraces")
                    //                        }
                    
                    MoreView(authViewModel: authVM)
                        .tabItem {
                            Label("More", systemImage: "ellipsis.circle")
                        }
                    
                }
                .onReceive(
                    NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
                ) { _ in
                    // Ask iOS again whenever the app returns to the foreground.
                    CheckpointMonitoringService.shared.scheduleBackgroundRefresh()
                }
                .onReceive(
                    NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
                ) { _ in
                    // Also (re-)submit right as we background — this is when iOS actually
                    // evaluates the request against usage heuristics, so a fresh
                    // earliestBeginDate here gives the system its best shot at honoring it.
                    CheckpointMonitoringService.shared.scheduleBackgroundRefresh()
                }

                .tint(Color(.systemPurple))
                
            } else {
                SignInView(authViewModel: authVM)
            }
        }
        .environmentObject(authVM) // Make AuthViewModel available throughout the app
        .modelContainer(modelContainer)
    }
}
