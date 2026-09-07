//
//  MonitoringSettings.swift
//  DevPoint
//
//  Created by mitz on 31/8/26.
//

import Foundation
import SwiftUI

enum CheckInterval: String, CaseIterable, Identifiable {
    case fiveMinutes
    case fifteenMinutes
    case thirtyMinutes
    case oneHour
    case sixHours
    case twelveHours
    case daily
    case manual

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fiveMinutes:
            return "Every 5 minutes"
        case .fifteenMinutes:
            return "Every 15 minutes"
        case .thirtyMinutes:
            return "Every 30 minutes"
        case .oneHour:
            return "Every hour"
        case .sixHours:
            return "Every 6 hours"
        case .twelveHours:
            return "Every 12 hours"
        case .daily:
            return "Once a day"
        case .manual:
            return "Manual only"
        }
    }

    var detail: String {
        switch self {
        case .manual:
            return "Checks run only when you open the app or pull to refresh."
        case .fiveMinutes, .fifteenMinutes:
            return "While the app is open, checks run on this schedule. In the background, iOS may batch them less often."
        default:
            return "Checks run on this schedule while the app is open, and iOS may run background refresh near this interval."
        }
    }

    /// Preferred delay between automatic checks. `nil` means automatic checks are off.
    var timeInterval: TimeInterval? {
        switch self {
        case .fiveMinutes:
            return 5 * 60
        case .fifteenMinutes:
            return 15 * 60
        case .thirtyMinutes:
            return 30 * 60
        case .oneHour:
            return 60 * 60
        case .sixHours:
            return 6 * 60 * 60
        case .twelveHours:
            return 12 * 60 * 60
        case .daily:
            return 24 * 60 * 60
        case .manual:
            return nil
        }
    }
}

/// How much slower than the expected baseline (in ms) counts as unacceptable latency.
enum ResponseTimeThreshold: String, CaseIterable, Identifiable {
    case off
    case ms250
    case ms500
    case ms1000
    case ms2000
    case ms3000
    case ms5000
    case ms10000

    var id: String { rawValue }

    var title: String {
        switch self {
        case .off:
            return "Don't monitor"
        case .ms250:
            return "250 ms slower"
        case .ms500:
            return "500 ms slower"
        case .ms1000:
            return "1,000 ms slower"
        case .ms2000:
            return "2,000 ms slower"
        case .ms3000:
            return "3,000 ms slower"
        case .ms5000:
            return "5,000 ms slower"
        case .ms10000:
            return "10,000 ms slower"
        }
    }

    var detail: String {
        switch self {
        case .off:
            return "Response times are still recorded in ms, but delays never change status or trigger notifications."
        default:
            return "If the latest response is at least this many milliseconds slower than the expected baseline, the checkpoint is marked Slow Response and can notify you."
        }
    }

    /// Extra latency over the expected baseline that is unacceptable, in milliseconds. `nil` disables slow checks.
    var milliseconds: Int? {
        switch self {
        case .off:
            return nil
        case .ms250:
            return 250
        case .ms500:
            return 500
        case .ms1000:
            return 1000
        case .ms2000:
            return 2000
        case .ms3000:
            return 3000
        case .ms5000:
            return 5000
        case .ms10000:
            return 10000
        }
    }
}

enum MonitoringSettings {
    static let checkIntervalKey = "monitoring.checkInterval"
    static let notificationsEnabledKey = "monitoring.notificationsEnabled"
    static let responseTimeThresholdKey = "monitoring.responseTimeThreshold"
    static let defaultCheckInterval = CheckInterval.fifteenMinutes
    static let defaultResponseTimeThreshold = ResponseTimeThreshold.ms2000

    static var checkInterval: CheckInterval {
        get {
            let raw = UserDefaults.standard.string(forKey: checkIntervalKey) ?? defaultCheckInterval.rawValue
            return CheckInterval(rawValue: raw) ?? defaultCheckInterval
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: checkIntervalKey)
        }
    }

    static var notificationsEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: notificationsEnabledKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: notificationsEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: notificationsEnabledKey)
        }
    }

    static var responseTimeThreshold: ResponseTimeThreshold {
        get {
            let raw = UserDefaults.standard.string(forKey: responseTimeThresholdKey)
                ?? defaultResponseTimeThreshold.rawValue
            return ResponseTimeThreshold(rawValue: raw) ?? defaultResponseTimeThreshold
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: responseTimeThresholdKey)
        }
    }
}

extension Checkpoint {
    /// Statuses that should surface a user notification after an automatic check.
    var needsAttention: Bool {
        switch status {
        case .healthy, .expectedMismatch, .unknown:
            return false
        case .unreachable, .warning, .serverError, .notFound, .responseMismatch, .slow:
            return true
        }
    }
}
