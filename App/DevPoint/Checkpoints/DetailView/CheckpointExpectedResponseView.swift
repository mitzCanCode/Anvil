//
//  CheckpointExpectedResponseView.swift
//  DevPoint
//
//  Created by mitz on 25/8/26.
//

import SwiftUI
import SwiftData

struct CheckpointExpectedResponseView: View {
    @Bindable var checkpoint: Checkpoint
    @Binding var ignoredLineNumbers: [Int]
    @Binding var ignoredHeaderNames: [String]
    @Environment(\.modelContext) private var modelContext
    
    @State private var isResetting = false
    @State private var resetProgress: String?
    @State private var resetError: String?
    @State private var showResetConfirmation = false
    
    var body: some View {
        List {
            if !checkpoint.expectedResponseHeaders.isEmpty || !checkpoint.lastResponseHeaders.isEmpty {
                Section {
                    IgnoredHeadersEditor(
                        headers: checkpoint.expectedResponseHeaders.isEmpty
                        ? checkpoint.lastResponseHeaders
                        : checkpoint.expectedResponseHeaders,
                        ignoredHeaderNames: $ignoredHeaderNames,
                        differingHeaderNames: differingHeaderNames(
                            expected: checkpoint.expectedResponseHeaders,
                            actual: checkpoint.lastResponseHeaders
                        )
                    )
                } header: {
                    Text("Headers")
                } footer: {
                    Text("Tap a header to ignore it during mismatch checks. Ignored headers are grayed out.")
                }
            }
            
            Section {
                IgnoredLinesEditor(
                    text: checkpoint.expectedResponse,
                    ignoredLineNumbers: $ignoredLineNumbers,
                    differingLineNumbers: differingLineNumbers(
                        expected: checkpoint.expectedResponse,
                        actual: checkpoint.lastResponse
                    )
                )
            } header: {
                Text("Body")
            } footer: {
                Text("Tap a line to ignore it during mismatch checks. Ignored lines are grayed out.")
            }
        }
        .navigationTitle("Expected Response")
        .navigationSubtitle(ignoredSummary)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: {
                    showResetConfirmation = true
                }) {
                    if isResetting {
                        ProgressView()
                    } else {
                        Label("Reset Expected Response", systemImage: "arrow.triangle.2.circlepath")
                    }
                }
                .confirmationDialog(
                    "Reset Expected Response?",
                    isPresented: $showResetConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Reset", role: .destructive) {
                        Task { await resetExpectedResponse() }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This replaces the current expected response, headers, and ignored fields using fresh samples from the site.")
                }
                .alert("Couldn't Reset Expected Response", isPresented: Binding(
                    get: { resetError != nil },
                    set: { if !$0 { resetError = nil } }
                )) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(resetError ?? "Unknown error")
                }
                .disabled(isResetting)
            }
        }
    }
    
    @MainActor
    private func resetExpectedResponse() async {
        guard !isResetting else { return }
        
        isResetting = true
        resetError = nil
        defer {
            isResetting = false
            resetProgress = nil
        }
        
        do {
            let sample = try await sampleResponseBaseline(from: checkpoint.url) { progress in
                resetProgress = progress
            }
            let result = sample.baseline
            
checkpoint.expectedResponse = result.body
            ignoredLineNumbers = sample.ignoredLineNumbers
            ignoredHeaderNames = sample.ignoredHeaderNames
            checkpoint.applyResponseResult(
                result,
                match: .exact,
                updateExpectedHeaders: true,
                expectedResponseTimeMs: sample.expectedResponseTimeMs
            )
            try? modelContext.save()
        } catch {
            resetError = error.localizedDescription
        }
    }
    
    private var ignoredSummary: String {
        let lineLabel = ignoredLineNumbers.count == 1 ? "line" : "lines"
        let headerLabel = ignoredHeaderNames.count == 1 ? "header" : "headers"
        return "\(ignoredLineNumbers.count) \(lineLabel), \(ignoredHeaderNames.count) \(headerLabel) ignored"
    }
}
