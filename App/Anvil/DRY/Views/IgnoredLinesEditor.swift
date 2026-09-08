//
//  IgnoredLinesEditor.swift
//  DevPoint
//
//  Created by mitz on 25/8/26.
//

import SwiftUI

/// GitHub-style numbered response body. Tap a line to toggle ignore.
struct IgnoredLinesEditor: View {
    /// Full response body text shown as ordered numbered lines.
    let text: String
    /// 1-based line numbers currently ignored.
    @Binding var ignoredLineNumbers: [Int]
    /// Optional 1-based lines to subtly highlight as currently differing.
    var differingLineNumbers: Set<Int> = []
    var footer: String = "Tap a line to ignore it during mismatch checks. Ignored lines are grayed out."
    
    private var lines: [String] {
        responseLines(from: text)
    }
    
    private var ignoredSet: Set<Int> {
        Set(ignoredLineNumbers)
    }
    
    var body: some View {
        if lines.isEmpty {
            Text("Empty body")
                .foregroundStyle(.secondary)
                .italic()
        } else {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                    let lineNumber = index + 1
                    let isIgnored = ignoredSet.contains(lineNumber)
                    let isDiffering = differingLineNumbers.contains(lineNumber)
                    
                    Button {
                        toggle(lineNumber)
                    } label: {
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text("\(lineNumber)")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(isIgnored ? Color.secondary.opacity(0.45) : Color.secondary)
                                .frame(width: 36, alignment: .trailing)
                                .padding(.trailing, 10)
                            
                            Text(line.isEmpty ? " " : line)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(isIgnored ? Color.secondary.opacity(0.45) : Color.primary)
                                .strikethrough(isIgnored, color: Color.secondary.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.vertical, 5)
                        //                            .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(rowBackground(isIgnored: isIgnored, isDiffering: isDiffering))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(accessibilityLabel(lineNumber: lineNumber, line: line, isIgnored: isIgnored))
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
    
    private func toggle(_ lineNumber: Int) {
        var next = ignoredLineNumbers
        if let index = next.firstIndex(of: lineNumber) {
            next.remove(at: index)
        } else {
            next.append(lineNumber)
            next.sort()
        }
        ignoredLineNumbers = next
    }
    
    private func accessibilityLabel(lineNumber: Int, line: String, isIgnored: Bool) -> String {
        let content = line.isEmpty ? "empty line" : line
        let state = isIgnored ? "ignored" : "active"
        return "Line \(lineNumber), \(state), \(content). Double tap to toggle."
    }
}

#Preview {
    Form {
        IgnoredLinesEditor(
            text: "{\n  \"ok\": true,\n  \"timestamp\": 123,\n  \"requestId\": \"abc\"\n}",
            ignoredLineNumbers: .constant([3]),
            differingLineNumbers: [3, 4]
        )
    }
}
