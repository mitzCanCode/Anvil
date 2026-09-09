//
//  IgnoredHeadersEditor.swift
//  DevPoint
//
//  Created by mitz on 31/8/26.
//

import SwiftUI

/// Header list matching `IgnoredLinesEditor`: tap a row to toggle ignore.
struct IgnoredHeadersEditor: View {
    /// Headers shown as ordered rows (typically expected/baseline headers).
    let headers: [String: String]
    /// Header names currently ignored (case-insensitive).
    @Binding var ignoredHeaderNames: [String]
    /// Header names to subtly highlight as currently differing.
    var differingHeaderNames: Set<String> = []
    var emptyMessage: String = "No headers"

    private var sortedKeys: [String] {
        headers.keys.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private var ignoredSet: Set<String> {
        Set(ignoredHeaderNames.map { $0.lowercased() })
    }

    private var differingSet: Set<String> {
        Set(differingHeaderNames.map { $0.lowercased() })
    }

    var body: some View {
        if sortedKeys.isEmpty {
            Text(emptyMessage)
                .foregroundStyle(.secondary)
                .italic()
        } else {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(sortedKeys, id: \.self) { key in
                    let value = headers[key] ?? ""
                    let isIgnored = ignoredSet.contains(key.lowercased())
                    let isDiffering = differingSet.contains(key.lowercased())

                    Button {
                        toggle(key)
                    } label: {
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Image(systemName: isIgnored ? "eye.slash" : "eye")
                                .font(.caption2)
                                .foregroundStyle(isIgnored ? Color.secondary.opacity(0.45) : Color.secondary)
                                .frame(width: 36, alignment: .trailing)
                                .padding(.trailing, 10)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(key)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(isIgnored ? Color.secondary.opacity(0.45) : Color.secondary)
                                    .strikethrough(isIgnored, color: Color.secondary.opacity(0.5))
                                Text(value.isEmpty ? " " : value)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(isIgnored ? Color.secondary.opacity(0.45) : Color.primary)
                                    .strikethrough(isIgnored, color: Color.secondary.opacity(0.5))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(rowBackground(isIgnored: isIgnored, isDiffering: isDiffering))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(accessibilityLabel(key: key, value: value, isIgnored: isIgnored))
                }
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 12))
        }
    }

    private func rowBackground(isIgnored: Bool, isDiffering: Bool) -> Color {
        if isIgnored {
            return Color.secondary.opacity(0.08)
        }
        if isDiffering {
            return Color.orange.opacity(0.10)
        }
        return Color.clear
    }

    private func toggle(_ headerName: String) {
        var next = ignoredHeaderNames
        let target = headerName.lowercased()
        if let index = next.firstIndex(where: { $0.lowercased() == target }) {
            next.remove(at: index)
        } else {
            next.append(headerName)
            next.sort { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        }
        ignoredHeaderNames = next
    }

    private func accessibilityLabel(key: String, value: String, isIgnored: Bool) -> String {
        let content = value.isEmpty ? "empty value" : value
        let state = isIgnored ? "ignored" : "active"
        return "Header \(key), \(state), \(content). Double tap to toggle."
    }
}

#Preview {
    Form {
        IgnoredHeadersEditor(
            headers: [
                "Content-Type": "application/json",
                "Date": "Mon, 01 Jan 2026 00:00:00 GMT",
                "Cache-Control": "max-age=0"
            ],
            ignoredHeaderNames: .constant(["Date"]),
            differingHeaderNames: ["Date", "Cache-Control"]
        )
    }
}
