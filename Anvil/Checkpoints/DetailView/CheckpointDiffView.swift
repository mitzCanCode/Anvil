//
//  CheckpointDiffView.swift
//  DevPoint
//
//  Created by mitz on 25/8/26.
//

import SwiftUI
import gitdiff

struct CheckpointDiffView: View {
    let checkpoint: Checkpoint
    @Environment(\.colorScheme) private var colorScheme
    @State private var unifiedDiff = ""
    
    private var matchKind: ResponseMatchKind {
        compareCheckpoint(
            expectedBody: checkpoint.expectedResponse,
            actualBody: checkpoint.lastResponse,
            ignoredLineNumbers: checkpoint.ignoredLineNumbers,
            expectedHeaders: checkpoint.expectedResponseHeaders,
            actualHeaders: checkpoint.lastResponseHeaders,
            ignoredHeaderNames: checkpoint.ignoredHeaderNames
        )
    }
    
    var body: some View {
        ScrollView {
            VStack {
                switch matchKind {
                case .exact:
                    ContentUnavailableView(
                        "Responses match",
                        systemImage: "checkmark.circle.fill",
                        description: Text("Expected and last response are identical.")
                    )
                case .expectedMismatch:
                    if unifiedDiff.isEmpty {
                        ContentUnavailableView(
                            "Only ignored fields differ",
                            systemImage: "checkmark.circle",
                            description: Text("No diff content to display.")
                        )
                    } else {
                        fullScreenDiff
                    }
                case .mismatch:
                    if unifiedDiff.isEmpty {
                        ContentUnavailableView(
                            "Unable to compute diff",
                            systemImage: "exclamationmark.triangle",
                            description: Text("Could not build a unified diff for these responses.")
                        )
                    } else {
                        fullScreenDiff
                    }
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .background(Color(.systemBackground))
        .onAppear { updateDiff() }
        .onChange(of: checkpoint.lastResponse) { _, _ in updateDiff() }
        .onChange(of: checkpoint.expectedResponse) { _, _ in updateDiff() }
        .navigationTitle("Latest Body")
        .navigationSubtitle("\(checkpoint.lastResponseTitle) - \(checkpoint.status.title)")
    }
    
    private var fullScreenDiff: some View {
        let theme: DiffTheme = colorScheme == .dark ? .dark : .light
        
        return DiffRenderer(diffText: unifiedDiff)
            .cornerRadius(16)
            .diffConfiguration(DiffConfiguration.mobile.with(theme: theme))
            .diffWordWrap(true)
            .diffFileHeaders(false)
            .diffHunkHeaders(false)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(colorScheme) // force refresh when appearance changes
    }
    
    private func updateDiff() {
        guard checkpoint.expectedResponse != checkpoint.lastResponse else {
            unifiedDiff = ""
            return
        }
        
        unifiedDiff = UnifiedDiffBuilder.make(
            oldText: checkpoint.expectedResponse,
            newText: checkpoint.lastResponse
        )
    }
}
