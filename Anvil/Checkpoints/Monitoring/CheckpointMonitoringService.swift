//
//  CheckpointMonitoringService.swift
//  DevPoint
//
//  Created by mitz on 31/8/26.
//

import BackgroundTasks
import Foundation
import SwiftData
import UIKit

@MainActor
final class CheckpointMonitoringService {
    static let shared = CheckpointMonitoringService()
    static let backgroundTaskIdentifier = "mitz.DevPoint.checkpointRefresh"

    private var modelContainer: ModelContainer?
    private var foregroundLoopTask: Task<Void, Never>?
    private var isRefreshing = false

    private init() {}

    func configure(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    static func registerBackgroundTasks() {
        let registered = BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }

            // Keep the system task alive until async work finishes.
            let semaphore = DispatchSemaphore(value: 0)
            Task { @MainActor in
                await shared.handleBackgroundRefresh(task: refreshTask)
                semaphore.signal()
            }
            semaphore.wait()
        }

        if !registered {
            print("BGTask register failed for \(backgroundTaskIdentifier) — check Info.plist identifiers")
        }
    }

    func start() {
        scheduleBackgroundRefresh()
        restartForegroundLoop()

        Task {
            await CheckpointNotificationManager.requestAuthorizationIfNeeded()
        }
    }

    func applySettingsChange() {
        scheduleBackgroundRefresh()
        restartForegroundLoop()
    }

    
    
    // run this in the LLDB console to check:
    //      e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"mitz.DevPoint.checkpointRefresh"]
    func scheduleBackgroundRefresh() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.backgroundTaskIdentifier)

        guard let interval = MonitoringSettings.checkInterval.timeInterval else { return }

        // Devices with Background App Refresh off reject submit with
        // BGTaskSchedulerErrorCode.unavailable (Code=1). Foreground looping still works.
        // Simulator often fails too, but we still attempt submit so LLDB
        // `_simulateLaunchForTaskWithIdentifier` has a pending request when it works.
        switch UIApplication.shared.backgroundRefreshStatus {
        case .denied, .restricted:
            print("Checkpoint BG schedule skipped: Background App Refresh is \(UIApplication.shared.backgroundRefreshStatus.rawValue)")
            return
        case .available:
            break
        @unknown default:
            break
        }

        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundTaskIdentifier)
        // iOS treats earliestBeginDate as a hint; keep a practical floor so short
        // intervals still request work without spamming the scheduler.
        // Use a short delay in DEBUG so simulate-launch is easier right after start.
        #if DEBUG
        let earliest = min(max(interval, 60), 15 * 60)
        #else
        let earliest = max(interval, 15 * 60)
        #endif
        request.earliestBeginDate = Date(timeIntervalSinceNow: earliest)

        do {
            try BGTaskScheduler.shared.submit(request)
            print("Scheduled checkpoint BG refresh (earliest in \(Int(earliest))s)")
        } catch let error as BGTaskScheduler.Error where error.code == .unavailable {
            // Expected on many Simulator builds, disabled refresh, or Low Power Mode.
            print("Checkpoint BG schedule unavailable (Code=1). Use Settings → Run checks now to test immediately.")
        } catch {
            print("Failed to schedule checkpoint refresh: \(error)")
        }
    }

    private func restartForegroundLoop() {
        foregroundLoopTask?.cancel()
        foregroundLoopTask = nil

        guard let interval = MonitoringSettings.checkInterval.timeInterval else { return }

        foregroundLoopTask = Task { @MainActor [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled else { break }

                // Only burn network while the app is visible.
                guard UIApplication.shared.applicationState == .active else { continue }

                _ = await self.refreshAllCheckpoints(notifyOnIssues: true)
            }
        }
    }

    private func handleBackgroundRefresh(task: BGAppRefreshTask) async {
        print("Background checkpoint refresh started")
        scheduleBackgroundRefresh()

        let refreshTask = Task { @MainActor in
            await refreshAllCheckpoints(notifyOnIssues: true)
        }

        task.expirationHandler = {
            refreshTask.cancel()
        }

        let success = await refreshTask.value
        print("Background checkpoint refresh finished success=\(success)")
        task.setTaskCompleted(success: success)
    }

    @discardableResult
    func refreshAllCheckpoints(notifyOnIssues: Bool) async -> Bool {
        guard !isRefreshing else { return true }
        guard let modelContainer else { return false }

        isRefreshing = true
        defer { isRefreshing = false }

        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<Checkpoint>(
            sortBy: [SortDescriptor(\.creationDate, order: .reverse)]
        )

        let checkpoints: [Checkpoint]
        do {
            checkpoints = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch checkpoints for monitoring: \(error)")
            return false
        }

        guard !checkpoints.isEmpty else { return true }

        await withTaskGroup(of: Void.self) { group in
            for checkpoint in checkpoints {
                group.addTask { @MainActor in
                    await Self.refresh(checkpoint)
                }
            }
        }

        do {
            try context.save()
        } catch {
            print("Failed to save checkpoint monitoring results: \(error)")
            return false
        }

        if notifyOnIssues {
            let attention = checkpoints.filter(\.needsAttention)
            await CheckpointNotificationManager.notifyAttentionNeeded(for: attention)
        }

        return true
    }

    @MainActor
    static func refresh(_ checkpoint: Checkpoint) async {
        let result = await requestUrl(
            checkpoint.url,
            headers: checkpoint.checkpointType == .api ? checkpoint.effectiveRequestHeaders : [:]
        )
        checkpoint.applyResponseResult(
            result,
            match: compareCheckpoint(
                expectedBody: checkpoint.expectedResponse,
                actualBody: result.body,
                ignoredLineNumbers: checkpoint.ignoredLineNumbers,
                expectedHeaders: checkpoint.expectedResponseHeaders,
                actualHeaders: result.headers,
                ignoredHeaderNames: checkpoint.ignoredHeaderNames
            )
        )
    }
}
