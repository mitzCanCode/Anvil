//
//  CheckpointRowView.swift
//  DevPoint
//
//  Created by mitz on 1/9/26.
//


import SwiftUI
import SwiftData

// MARK: - Row
struct CheckpointRowView: View {
    let checkpoint: Checkpoint
    let isRefreshing: Bool
    let now: Date
    
    private var hostDisplay: String {
        let host = checkpoint.url.host() ?? checkpoint.url.absoluteString
        if let port = checkpoint.url.port {
            return "\(host):\(port)"
        }
        return host
    }
    
    private var pathDisplay: String? {
        let path = checkpoint.url.path
        let query = checkpoint.url.query.map { "?\($0)" } ?? ""
        let combined = path + query
        guard !combined.isEmpty, combined != "/" else { return nil }
        return combined
    }
    
    private var statusCodeDisplay: String? {
        let code = checkpoint.lastResponseStatusCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty, code != "—" else { return nil }
        return code
    }
    
    private var contentTypeDisplay: String? {
        let value = checkpoint.lastResponseDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return nil }
        // Keep the list scannable: show the media type without parameters.
        return value.split(separator: ";", maxSplits: 1).first.map(String.init) ?? value
    }
    
    private var lastCheckedDisplay: String {
        let elapsed = now.timeIntervalSince(checkpoint.lastRunDate)
        if elapsed < 60 {
            return "Checked just now"
        }
        return "Checked \(Self.relativeDateFormatter.localizedString(for: checkpoint.lastRunDate, relativeTo: now))"
    }
    
    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    
                    Image(systemName: checkpoint.checkpointType.icon)
                        .foregroundStyle(checkpoint.status.color)
                        .font(.body)
                        .shadow(color: checkpoint.status.color, radius: 4)
                    Text(checkpoint.name)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                }
                
                HStack {
                    Image(systemName: "link")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                    Text(checkpoint.url.absoluteString)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
                HStack {
                    Image(systemName: "gauge.open.with.lines.needle.33percent")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                    Text(checkpoint.lastResponseTimeMs.formatted())
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
                
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if isRefreshing {
                    ProgressView()
                        .controlSize(.mini)
                } else {
                    Text(checkpoint.status.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(checkpoint.status.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(checkpoint.status.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                
                Text(isRefreshing ? "Checking live" : lastCheckedDisplay)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                
                Text("Status code: \(isRefreshing ? "—" : checkpoint.lastResponseStatusCode)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }
    
    private var responseTimeColor: Color {
        checkpoint.isResponseTooSlow ? .yellow : Color(.tertiaryLabel)
    }
    
    private var urlBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(hostDisplay)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
    
    private func statusCodeColor(for codeString: String) -> Color {
        guard let code = Int(codeString) else { return checkpoint.status.color }
        switch code {
        case 200..<300:
            return .green
        case 300..<400:
            return .yellow
        case 400..<500:
            return .orange
        case 500..<600:
            return .red
        default:
            return checkpoint.status.color
        }
    }
    
    private var accessibilitySummary: String {
        var parts = [
            checkpoint.name,
            checkpoint.checkpointType.title,
            checkpoint.status.title,
            hostDisplay
        ]
        if let pathDisplay { parts.append(pathDisplay) }
        if let statusCodeDisplay { parts.append("HTTP \(statusCodeDisplay)") }
        if let contentTypeDisplay { parts.append(contentTypeDisplay) }
        if checkpoint.lastResponseTimeMs > 0 {
            parts.append(checkpoint.lastResponseTimeMs.formatted())
        }
        parts.append(lastCheckedDisplay)
        return parts.joined(separator: ", ")
    }
}

#Preview {
    let now = Date()
    
    let healthy = Checkpoint(
        name: "Example API",
        url: URL(string: "https://api.example.com/v1/health?region=us")!,
        expectedResponse: "{\"ok\":true}"
    )
    healthy.status = .healthy
    healthy.lastResponseStatusCode = "200"
    healthy.lastResponseDescription = "application/json; charset=utf-8"
    healthy.expectedResponseTimeMs = 120
    healthy.lastResponseTimeMs = 135
    healthy.lastRunDate = now.addingTimeInterval(-45)
    
    let mismatch = Checkpoint(
        name: "Marketing Site",
        url: URL(string: "https://example.com:8443/status")!,
        expectedResponse: "ok",
        checkpointType: .api
    )
    mismatch.status = .responseMismatch
    mismatch.lastResponseStatusCode = "200"
    mismatch.lastResponseDescription = "text/html"
    mismatch.expectedResponseTimeMs = 210
    mismatch.lastResponseTimeMs = 980
    mismatch.lastRunDate = now.addingTimeInterval(-60 * 12)
    mismatch.ignoredLineNumbers = [3, 8]
    mismatch.ignoredHeaderNames = ["Date", "Age"]
    
    let unreachable = Checkpoint(
        name: "Staging",
        url: URL(string: "https://staging.internal")!,
        expectedResponse: ""
    )
    unreachable.status = .unreachable
    unreachable.lastResponseStatusCode = "—"
    unreachable.lastResponseDescription = "The Internet connection appears to be offline."
    unreachable.lastRunDate = now.addingTimeInterval(-60 * 60 * 3)
    
    return List {
        CheckpointRowView(checkpoint: healthy, isRefreshing: false, now: now)
        CheckpointRowView(checkpoint: mismatch, isRefreshing: true, now: now)
        CheckpointRowView(checkpoint: unreachable, isRefreshing: false, now: now)
    }
    .modelContainer(for: Checkpoint.self, inMemory: true)
}
