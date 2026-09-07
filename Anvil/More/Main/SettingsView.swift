//
//  SettingsView.swift
//  DevPoint
//
//  Created by mitz on 31/8/26.
//

import SwiftUI
import UIKit
import UserNotifications

struct SettingsView: View {
@AppStorage(MonitoringSettings.checkIntervalKey)
    private var checkIntervalRawValue = MonitoringSettings.defaultCheckInterval.rawValue

    @AppStorage(MonitoringSettings.notificationsEnabledKey)
    private var notificationsEnabled = true

    @AppStorage(MonitoringSettings.responseTimeThresholdKey)
    private var responseTimeThresholdRawValue = MonitoringSettings.defaultResponseTimeThreshold.rawValue

    @State private var notificationAuthorization: UNAuthorizationStatus = .notDetermined
    @Environment(\.openURL) private var openURL

    private var selectedInterval: CheckInterval {
        CheckInterval(rawValue: checkIntervalRawValue) ?? MonitoringSettings.defaultCheckInterval
    }

    private var selectedResponseTimeThreshold: ResponseTimeThreshold {
        ResponseTimeThreshold(rawValue: responseTimeThresholdRawValue)
            ?? MonitoringSettings.defaultResponseTimeThreshold
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Check frequency", selection: $checkIntervalRawValue) {
                        ForEach(CheckInterval.allCases) { interval in
                            Text(interval.title).tag(interval.rawValue)
                        }
                    }
                    .tint(Color.accent)
                    .onChange(of: checkIntervalRawValue) { _, _ in
                        CheckpointMonitoringService.shared.applySettingsChange()
                    }
                } header: {
                    Text("Automatic checks")
                } footer: {
                    Text(selectedInterval.detail)
                }

                Section {
                    Picker("Unacceptable delay", selection: $responseTimeThresholdRawValue) {
                        ForEach(ResponseTimeThreshold.allCases) { threshold in
                            Text(threshold.title).tag(threshold.rawValue)
                        }
                    }
                    .tint(Color.accent)
                } header: {
                    Text("Response time")
                } footer: {
                    Text(selectedResponseTimeThreshold.detail)
                }

                Section {
                    Toggle("Notify when attention is needed", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, isEnabled in
                            guard isEnabled else { return }
                            Task {
                                await CheckpointNotificationManager.requestAuthorizationIfNeeded()
                                await refreshNotificationAuthorization()
                            }
                        }

                    if notificationsEnabled {
                        notificationStatusRow
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("You’ll only be notified when a scheduled check finds a problem (unreachable, mismatch, slow response, server error, and similar). Healthy and expected-mismatch results stay quiet.")
                }
            }
            .navigationTitle("Settings")
            .task {
                await refreshNotificationAuthorization()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await refreshNotificationAuthorization()
                }
            }
        }
    }

    @ViewBuilder
    private var notificationStatusRow: some View {
        switch notificationAuthorization {
        case .authorized, .provisional, .ephemeral:
            Label("Notifications allowed", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.secondary)
        case .denied:
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            } label: {
                Label("Open System Settings to allow notifications", systemImage: "bell.slash")
            }
        case .notDetermined:
            Button {
                Task {
                    await CheckpointNotificationManager.requestAuthorizationIfNeeded()
                    await refreshNotificationAuthorization()
                }
            } label: {
                Label("Allow notifications", systemImage: "bell.badge")
            }
        @unknown default:
            EmptyView()
        }
    }

    private func refreshNotificationAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationAuthorization = settings.authorizationStatus
    }
}

#Preview {
    SettingsView()
}
