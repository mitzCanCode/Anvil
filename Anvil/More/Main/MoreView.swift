//
//  MoreView.swift
//  Anvil
//
//  Created by Dimitris Chatzigeorgiou on 25/8/25.
//

import SwiftUI
import UIKit
import UserNotifications

struct MoreView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage(MonitoringSettings.checkIntervalKey)
    private var checkIntervalRawValue = MonitoringSettings.defaultCheckInterval.rawValue
    
    @AppStorage(MonitoringSettings.notificationsEnabledKey)
    private var notificationsEnabled = true
    
    @AppStorage(MonitoringSettings.responseTimeThresholdKey)
    private var responseTimeThresholdRawValue = MonitoringSettings.defaultResponseTimeThreshold.rawValue
    @State private var notificationAuthorization: UNAuthorizationStatus = .notDetermined
    
    init(authViewModel: AuthViewModel) {
        _authViewModel = ObservedObject(wrappedValue: authViewModel)
    }
    private var selectedInterval: CheckInterval {
        CheckInterval(rawValue: checkIntervalRawValue) ?? MonitoringSettings.defaultCheckInterval
    }
    
    private var selectedResponseTimeThreshold: ResponseTimeThreshold {
        ResponseTimeThreshold(rawValue: responseTimeThresholdRawValue)
        ?? MonitoringSettings.defaultResponseTimeThreshold
    }
    
    var body: some View {
        NavigationView {
            List {
                // User Profile Section
                Section {
                    HStack(spacing: 16) {
                        // Profile Image Placeholder
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authViewModel.user?.displayName ?? "GitHub User")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            if let email = authViewModel.user?.email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("User ID: \(authViewModel.user?.uid.prefix(8) ?? "Unknown")...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .listRowBackground(Color.clear)
                
                // App Settings Section
                Section("Settings") {
                    VStack {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("About")
                            Spacer()
                            Text("Version 1.0")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            Text("Help & Support")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        
                        HStack {
                            Image(systemName: "star.circle")
                                .foregroundColor(.yellow)
                                .frame(width: 24)
                            Text("Rate App")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .padding()
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .listRowBackground(Color.clear)
                
                
                Section {
                    VStack {
                        Picker("Check frequency", selection: $checkIntervalRawValue) {
                            ForEach(CheckInterval.allCases) { interval in
                                Text(interval.title).tag(interval.rawValue)
                            }
                        }
                        .tint(Color.accent)
                        .onChange(of: checkIntervalRawValue) { _, _ in
                            CheckpointMonitoringService.shared.applySettingsChange()
                        }
                    }
                    .padding()
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                } header: {
                    Text("Automatic checks")
                } footer: {
                    Text(selectedInterval.detail)
                }
                .listRowBackground(Color.clear)
                
                
                Section {
                    VStack {
                        Picker("Unacceptable delay", selection: $responseTimeThresholdRawValue) {
                            ForEach(ResponseTimeThreshold.allCases) { threshold in
                                Text(threshold.title).tag(threshold.rawValue)
                            }
                        }
                        .tint(Color.accent)
                    }
                    .padding()
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                } header: {
                    Text("Response time")
                } footer: {
                    Text(selectedResponseTimeThreshold.detail)
                }
                .listRowBackground(Color.clear)
                
                Section {
                    VStack {
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
                }
                .padding()
                .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("You’ll only be notified when a scheduled check finds a problem (unreachable, mismatch, slow response, server error, and similar). Healthy and expected-mismatch results stay quiet.")
                }
                .listRowBackground(Color.clear)
                
                // Account Section
                Section("Account") {
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("Sign Out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color.clear)

                
                // Footer Section
                Section {
                    VStack(spacing: 12) {
                        Text("Anvil")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("Built with SwiftUI and Firebase")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("© 2025 mitzCanCode")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                .listRowBackground(Color.clear)

            }
            .listStyle(.automatic)
            .scrollContentBackground(.hidden)
            .customViewBackground()
            .navigationTitle("More")
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
    MoreView(authViewModel: AuthViewModel())
}
