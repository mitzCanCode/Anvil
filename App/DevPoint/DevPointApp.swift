//
//  DevPointApp.swift
//  DevPoint
//
//  Created by Dimitris Chatzigeorgiou on 24/8/25.
//

import SwiftUI
import UIKit
import SwiftData


@main
struct DevPointApp: App {
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
            TabView {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "chart.bar")
                    }
                
                CheckpointsView()
                    .tabItem {
                        Label("Websites", systemImage: "network")
                    }
                
                PaletteGeneratorView()
                    .tabItem {
                        Label("Palette", systemImage: "paintbrush.fill")
                    }
                
                MoreView(authViewModel: authVM)
                    .tabItem {
                        Label("More", systemImage: "ellipsis.circle")
                    }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            ) { _ in
                CheckpointMonitoringService.shared.scheduleBackgroundRefresh()
            }
            .onReceive(
                NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            ) { _ in
                CheckpointMonitoringService.shared.scheduleBackgroundRefresh()
            }
            .tint(Color(.systemPurple))
        }
        .environmentObject(authVM)
        .modelContainer(modelContainer)
    }
}
