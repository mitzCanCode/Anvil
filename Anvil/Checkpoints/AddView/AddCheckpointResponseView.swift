//
//  AddCheckpointResponseView.swift
//  DevPoint
//
//  Created by mitz on 24/8/26.
//

import SwiftUI

struct AddCheckpointResponseView: View {
    let name: String
    let url: URL
    let result: URLResponseResult
    let expectedResponseTimeMs: Int
    @Binding var ignoredLineNumbers: [Int]
    @Binding var ignoredHeaderNames: [String]
    let onSave: () -> Void
    
    var body: some View {
        Form {
            overviewSection
            
            if !result.headers.isEmpty {
                Section {
                    IgnoredHeadersEditor(
                        headers: result.headers,
                        ignoredHeaderNames: $ignoredHeaderNames
                    )
                } header: {
                    Text("Headers")
                } footer: {
                    Text("Tap a header to ignore it during mismatch checks. Ignored headers are grayed out.")
                }
            }
            Section {
                IgnoredLinesEditor(
                    text: result.body,
                    ignoredLineNumbers: $ignoredLineNumbers
                )
            } header: {
                Text("Body")
            } footer: {
                Text("Tap a line to ignore it during mismatch checks. Ignored lines are grayed out.")
            }
        }
        .navigationTitle("Overview")
        .navigationSubtitle("Please review the sample response before saving the checkpoint.")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: onSave) {
                    Label("Save Checkpoint", systemImage: "checkmark")
                }
                .disabled(result.statusCode < 200 || result.statusCode >= 300)
            }
        }
    }
    
    private var overviewSection: some View {
        Section {
            LabeledContent("Name") {
                Text(name)
                    .foregroundStyle(.secondary)
            }
            
            LabeledContent("URL") {
                Text(url.absoluteString)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)
            }
            
            LabeledContent("Response Status") {
                ResponseStatusBadge(statusCode: result.statusCode)
            }
            
            LabeledContent("Expected Response Time") {
                Text(expectedResponseTimeMs.formatted())
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Overview")
        } footer: {
            Text("Expected response time is the average of the sample requests, in milliseconds.")
        }
    }
    
    
}

struct ResponseStatusBadge: View {
    let statusCode: Int
    
    private var title: String {
        switch statusCode {
        case 200...299: return "Success"
        case 400...499: return "Client Error"
        case 500...599: return "Server Error"
        case -1: return "Unreachable"
        default: return "Unknown"
        }
    }
    
    private var icon: String {
        switch statusCode {
        case 200...299: return "checkmark.seal.fill"
        case 400...499: return "exclamationmark.triangle.fill"
        case 500...599: return "xmark.octagon.fill"
        case -1: return "wifi.slash"
        default: return "questionmark.circle.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Text(Image(systemName: icon))
            Text("\(title) (\(statusCode))")
        }
        .foregroundStyle(Self.color(for: statusCode))
    }
    
    static func color(for code: Int) -> Color {
        switch code {
        case 200...299: return .green
        case 400...499: return .orange
        case 500...599: return .red
        case -1: return .red
        default: return .gray
        }
    }
}

struct ResponseHeaderRow: View {
    let key: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.footnote, design: .monospaced))
                .textSelection(.enabled)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        AddCheckpointResponseView(
            name: "Example",
            url: URL(string: "https://example.com")!,
            result: URLResponseResult(
                statusCode: 200,
                body: "{\"ok\":true}\ntimestamp: 1",
                headers: ["Content-Type": "application/json"],
                responseTimeMs: 142
            ),
            expectedResponseTimeMs: 156,
            ignoredLineNumbers: .constant([2]),
            ignoredHeaderNames: .constant(["Date"]),
            onSave: {}
        )
        .navigationTitle("Review Response")
    }
}
