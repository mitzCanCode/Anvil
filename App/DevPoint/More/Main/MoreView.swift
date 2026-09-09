//
//  MoreView.swift
//  DevPoint
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
            ScrollView {
                VStack(spacing: 15) {
                    profileSegment
                    
                    toolSegment
                    
                    automaticChecksSegment
                    
                    responseTimeSegment
                    
                    notificationsSegment
                    
                    aboutSegment
                    
                    if authViewModel.hasAccessToken {
                        accountSegment
                    }
                    
                    footerSegment
                }
                .padding()
            }
            .customViewBackground()
            .navigationTitle("More")
            .task {
                await refreshNotificationAuthorization()
                await authViewModel.refreshUser()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await refreshNotificationAuthorization()
                }
            }
        }
    }
    
    // MARK: - Profile
    
    private var profileSegment: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(authViewModel.user?.name ?? authViewModel.user?.login ?? "GitHub not connected")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if let login = authViewModel.user?.login {
                    Text("@\(login)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(authViewModel.hasAccessToken ? "GitHub connected" : "GitHub dashboard is optional")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 15))
    }
    
    // MARK: - Automatic Checks
    
    private var automaticChecksSegment: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center) {
                Image(systemName: "clock.arrow.trianglehead.2.counterclockwise.rotate.90")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading) {
                    Text("Automatic checks")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(selectedInterval.detail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack {
                Spacer()
                Picker("Check frequency", selection: $checkIntervalRawValue) {
                    ForEach(CheckInterval.allCases) { interval in
                        Text(interval.title).tag(interval.rawValue)
                    }
                }
                Spacer()
            }
            .tint(Color.accent)
            .onChange(of: checkIntervalRawValue) { _, _ in
                CheckpointMonitoringService.shared.applySettingsChange()
            }
            .padding()
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15))
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 15))
    }
    
    // MARK: - Response Time
    
    private var responseTimeSegment: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center) {
                Image(systemName: "gauge.with.dots.needle.67percent")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading) {
                    Text("Response time")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(selectedResponseTimeThreshold.detail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack {
                Spacer()
                
                Picker("Unacceptable delay", selection: $responseTimeThresholdRawValue) {
                    ForEach(ResponseTimeThreshold.allCases) { threshold in
                        Text(threshold.title).tag(threshold.rawValue)
                        
                    }
                }
                Spacer()
            }
            .tint(Color.accent)
            .padding()
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15))
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 15))
    }
    
    // MARK: - Notifications
    
    private var notificationsSegment: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center) {
                Image(systemName: "bell.badge.fill")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading) {
                    Text("Notifications")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("You’ll only be notified when a scheduled check finds a problem (unreachable, mismatch, slow response, server error, and similar). Healthy and expected-mismatch results stay quiet.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            Toggle("Notify when attention is needed", isOn: $notificationsEnabled)
                .onChange(of: notificationsEnabled) { _, isEnabled in
                    guard isEnabled else { return }
                    Task {
                        await CheckpointNotificationManager.requestAuthorizationIfNeeded()
                        await refreshNotificationAuthorization()
                    }
                }
                .padding()
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15))
            
            if notificationsEnabled {
                notificationStatusRow
                    .frame(maxWidth: .infinity)
                    .padding()
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15))
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 15))
    }
    
    // MARK: - Tools
    
    private var toolSegment: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center) {
                Image(systemName: "display.and.screwdriver")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading) {
                    Text("Tools")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Quick utilities for everyday coding tasks.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                navigationRow(title: "Calculator", destination: CalculatorView()) {
                    Image(systemName: "function")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                }
                
                navigationRow(title: "Regex Generator", destination: RegexGeneratorView()) {
                    Image(systemName: "textformat.abc.dottedunderline")
                        .foregroundColor(.purple)
                        .frame(width: 24)
                }
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 15))
    }
    
    
    // MARK: - About
    
    private var aboutSegment: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center) {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.accentColor)
                
                Text("About")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    Text("Version")
                    Spacer()
                    Text("1.0")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15))
                
                linkRow(title: "Website", url: DevPointLinks.website) {
                    Image(systemName: "globe")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                }
                
                linkRow(title: "GitHub", url: DevPointLinks.github) {
                    Image(colorScheme == .dark ? "github-dark" : "github-light")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .frame(width: 24)
                }
                
                linkRow(title: "Privacy Policy", url: DevPointLinks.privacy) {
                    Image(systemName: "hand.raised.circle")
                        .foregroundColor(.purple)
                        .frame(width: 24)
                }
                
                linkRow(title: "Terms of Service", url: DevPointLinks.terms) {
                    Image(systemName: "doc.text")
                        .foregroundColor(.orange)
                        .frame(width: 24)
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
                .padding()
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15))
                
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
                .padding()
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15))
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 15))
    }
    
    @ViewBuilder
    private func linkRow<Icon: View>(
        title: String,
        url: URL,
        @ViewBuilder icon: () -> Icon
    ) -> some View {
        Link(destination: url) {
            HStack {
                icon()
                Text(title)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .padding()
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15))
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func navigationRow<Destination: View, Icon: View>(
        title: String,
        destination: Destination,
        @ViewBuilder icon: () -> Icon
    ) -> some View {
        NavigationLink {
            destination
        } label: {
            HStack {
                icon()
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .padding()
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Account
    
    private var accountSegment: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center) {
                Image(systemName: "person.crop.circle.badge.minus")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.red)
                
                VStack(alignment: .leading) {
                    Text("Account")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Disconnect GitHub access from DevPoint.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            Button(action: {
                authViewModel.signOut()
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "link.badge.minus")
                    Text("Disconnect GitHub")
                        .bold()
                    Spacer()
                }
                .foregroundColor(.red)
                .padding()
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 15))
            }
        }
        .padding()
        .glassEffect(.regular.tint(.red.opacity(0.05)), in: .rect(cornerRadius: 15))
    }
    
    // MARK: - Footer
    
    private var footerSegment: some View {
        VStack(spacing: 12) {
            Text("DevPoint")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Built with SwiftUI")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("© 2026 mitzCanCode")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
    
    // MARK: - Notification Status
    
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

// MARK: - Links

enum DevPointLinks {
    static let website = URL(string: "https://devpoint.mitz.codes")!
    static let github = URL(string: "https://github.com/mitzCanCode/DevPoint")!
    static let privacy = URL(string: "https://devpoint.mitz.codes/legal.html#privacy")!
    static let terms = URL(string: "https://devpoint.mitz.codes/legal.html#terms")!
}

#Preview {
    MoreView(authViewModel: AuthViewModel())
}
