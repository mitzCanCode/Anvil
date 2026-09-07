//
//  CheckpointNotificationManager.swift
//  DevPoint
//
//  Created by mitz on 31/8/26.
//

import Foundation
import UserNotifications

enum CheckpointNotificationManager {
    static let categoryIdentifier = "CHECKPOINT_ATTENTION"

    static func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        default:
            break
        }

        let category = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
    }

    /// Posts a local notification. Returns whether it was enqueued.
    @discardableResult
    static func notifyAttentionNeeded(for checkpoints: [Checkpoint]) async -> Bool {
        guard MonitoringSettings.notificationsEnabled else {
            print("Checkpoint notification skipped: disabled in Settings")
            return false
        }
        guard !checkpoints.isEmpty else {
            print("Checkpoint notification skipped: no checkpoints need attention")
            return false
        }

        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional
                || settings.authorizationStatus == .ephemeral
        else {
            print("Checkpoint notification skipped: authorization is \(settings.authorizationStatus.rawValue)")
            return false
        }

        let content = UNMutableNotificationContent()
        content.categoryIdentifier = categoryIdentifier
        content.sound = .default
        // Required on newer iOS for reliable banner presentation.
        content.title = checkpoints.count == 1 ? "Checkpoint needs attention" : "Checkpoints need attention"

if checkpoints.count == 1, let checkpoint = checkpoints.first {
            if checkpoint.status == .slow {
                content.body = "\(checkpoint.name) responded in \(checkpoint.lastResponseTimeMs.formatted()) (\(checkpoint.responseTimeDeltaMs.formatted()) slower than expected)."
            } else {
                content.body = "\(checkpoint.name) is \(checkpoint.status.title.lowercased())."
            }
            content.userInfo = ["checkpointName": checkpoint.name]
        } else {
            let names = checkpoints.prefix(3).map(\.name).joined(separator: ", ")
            let remaining = checkpoints.count - min(checkpoints.count, 3)
            if remaining > 0 {
                content.body = "\(names), and \(remaining) more need a look."
            } else {
                content.body = "\(names) need a look."
            }
        }

        let request = UNNotificationRequest(
            identifier: "checkpoint-attention-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        do {
            try await center.add(request)
            print("Checkpoint notification scheduled for \(checkpoints.count) issue(s)")
            return true
        } catch {
            print("Checkpoint notification failed: \(error)")
            return false
        }
    }

    /// Debug/help path so you can verify banners without a failing site.
    static func sendTestNotification() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional
                || settings.authorizationStatus == .ephemeral
        else {
            print("Test notification skipped: not authorized")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "DevPoint"
        content.body = "Test notification — alerts are working."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "checkpoint-test-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        try? await center.add(request)
    }
}
