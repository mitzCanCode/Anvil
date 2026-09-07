//
//  CheckpointHeadersView.swift
//  DevPoint
//
//  Created by mitz on 26/8/26.
//

import SwiftUI
import SwiftData

struct CheckpointHeadersView: View {
    let checkpoint: Checkpoint

    private var expectedHeaders: [String: String] {
        checkpoint.expectedResponseHeaders
    }

    private var actualHeaders: [String: String] {
        checkpoint.lastResponseHeaders
    }

    private var rows: [HeaderDiffRow] {
        headerDiffRows(expected: expectedHeaders, actual: actualHeaders)
    }

    private var ignoredSet: Set<String> {
        Set(checkpoint.ignoredHeaderNames.map { $0.lowercased() })
    }

    var body: some View {
        List {
            if rows.isEmpty {
                ContentUnavailableView(
                    "No Headers",
                    systemImage: "list.bullet.rectangle",
                    description: Text("Refresh this checkpoint to capture response headers.")
                )
            } else {
                Section {
                    ForEach(rows) { row in
                        HeaderDiffRowView(
                            row: row,
                            isIgnored: ignoredSet.contains(row.lowercasedName)
                        )
                    }
                } footer: {
                    if !checkpoint.ignoredHeaderNames.isEmpty {
                        Text("Grayed headers are ignored during mismatch checks. Manage ignores in Expected Response.")
                    }
                }
            }
        }
        .navigationTitle("Latest Headers")
        .navigationSubtitle(subtitle)
    }

    private var subtitle: String {
        let total = rows.count
        let changed = rows.filter { $0.kind != .equal }.count
        let headerWord = total == 1 ? "header" : "headers"
        if changed == 0 {
            return "\(total) \(headerWord) from the latest response."
        }
        let changeWord = changed == 1 ? "difference" : "differences"
        return "\(total) \(headerWord), \(changed) \(changeWord)."
    }
}

// MARK: - Diff model

private enum HeaderDiffKind {
    case equal
    case changed
    case removed
    case added
}

private struct HeaderDiffRow: Identifiable {
    let id: String
    let name: String
    let lowercasedName: String
    let expectedValue: String?
    let actualValue: String?
    let kind: HeaderDiffKind
}

private func headerDiffRows(
    expected: [String: String],
    actual: [String: String]
) -> [HeaderDiffRow] {
    let expectedByLower = Dictionary(
        uniqueKeysWithValues: expected.map { ($0.key.lowercased(), ($0.key, $0.value)) }
    )
    let actualByLower = Dictionary(
        uniqueKeysWithValues: actual.map { ($0.key.lowercased(), ($0.key, $0.value)) }
    )

    let keys = Set(expectedByLower.keys).union(actualByLower.keys)
        .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }

    return keys.map { key in
        let expectedEntry = expectedByLower[key]
        let actualEntry = actualByLower[key]
        let displayName = actualEntry?.0 ?? expectedEntry?.0 ?? key
        let expectedValue = expectedEntry?.1
        let actualValue = actualEntry?.1

        let kind: HeaderDiffKind
        switch (expectedValue, actualValue) {
        case let (expected?, actual?) where expected == actual:
            kind = .equal
        case (_?, _?):
            kind = .changed
        case (_?, nil):
            kind = .removed
        case (nil, _?):
            kind = .added
        case (nil, nil):
            kind = .equal
        }

        return HeaderDiffRow(
            id: key,
            name: displayName,
            lowercasedName: key,
            expectedValue: expectedValue,
            actualValue: actualValue,
            kind: kind
        )
    }
}

// MARK: - Row views

private struct HeaderDiffRowView: View {
    let row: HeaderDiffRow
    var isIgnored: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(row.name)
                .font(.caption)
                .foregroundStyle(isIgnored ? Color.secondary.opacity(0.45) : Color.secondary)
                .strikethrough(isIgnored, color: Color.secondary.opacity(0.5))

            switch row.kind {
            case .equal:
                Text(row.actualValue ?? row.expectedValue ?? "")
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(isIgnored ? Color.secondary.opacity(0.45) : Color.primary)
                    .strikethrough(isIgnored, color: Color.secondary.opacity(0.5))
                    .textSelection(.enabled)

            case .changed:
                GitHeaderValueLine(prefix: "-", value: row.expectedValue ?? "", style: .removed, dimmed: isIgnored)
                GitHeaderValueLine(prefix: "+", value: row.actualValue ?? "", style: .added, dimmed: isIgnored)

            case .removed:
                GitHeaderValueLine(prefix: "-", value: row.expectedValue ?? "", style: .removed, dimmed: isIgnored)

            case .added:
                GitHeaderValueLine(prefix: "+", value: row.actualValue ?? "", style: .added, dimmed: isIgnored)
            }
        }
        .padding(.vertical, 2)
        .opacity(isIgnored ? 0.85 : 1)
    }
}

private enum GitHeaderLineStyle {
    case added
    case removed

    var foreground: Color {
        switch self {
        case .added: return Color.green
        case .removed: return Color.red
        }
    }

    var background: Color {
        switch self {
        case .added: return Color.green.opacity(0.12)
        case .removed: return Color.red.opacity(0.12)
        }
    }
}

private struct GitHeaderValueLine: View {
    let prefix: String
    let value: String
    let style: GitHeaderLineStyle
    var dimmed: Bool = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(prefix)
                .font(.system(.footnote, design: .monospaced).weight(.semibold))
                .foregroundStyle(style.foreground.opacity(dimmed ? 0.45 : 1))
            Text(value.isEmpty ? " " : value)
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(style.foreground.opacity(dimmed ? 0.45 : 1))
                .strikethrough(dimmed, color: Color.secondary.opacity(0.5))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(style.background.opacity(dimmed ? 0.45 : 1))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

#Preview {
    let checkpoint = Checkpoint(
        name: "Example",
        url: URL(string: "https://example.com")!,
        expectedResponse: "{\"ok\":true}"
    )
    checkpoint.lastResponseTitle = "HTTP 200"
    checkpoint.expectedResponseHeaders = [
        "Content-Type": "application/json",
        "Cache-Control": "max-age=0",
        "Date": "Mon, 01 Jan 2026 00:00:00 GMT",
        "X-Old": "gone"
    ]
    checkpoint.lastResponseHeaders = [
        "Content-Type": "application/json",
        "Cache-Control": "no-cache",
        "Date": "Tue, 02 Jan 2026 00:00:00 GMT",
        "X-New": "added"
    ]
    checkpoint.ignoredHeaderNames = ["Date"]

    return NavigationStack {
        CheckpointHeadersView(checkpoint: checkpoint)
    }
    .modelContainer(for: Checkpoint.self, inMemory: true)
}
