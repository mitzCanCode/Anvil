//
//  CheckpointsView.swift
//  DevPoint
//
//  Created by mitz on 24/8/26.
//

import SwiftUI
import SwiftData

struct CheckpointsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Checkpoint.creationDate, order: .reverse) private var checkpoints: [Checkpoint]
    
    @State private var showSheet = false
    @State private var selectedCheckpoint: Checkpoint?
    @State private var isRefreshing = false
    @State private var searchText = ""
    @State private var now = Date()
    
    private var filteredCheckpoints: [Checkpoint] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return checkpoints }
        
        return checkpoints.filter { checkpoint in
            checkpoint.name.localizedCaseInsensitiveContains(query)
            || checkpoint.url.absoluteString.localizedCaseInsensitiveContains(query)
            || checkpoint.status.title.localizedCaseInsensitiveContains(query)
            || checkpoint.checkpointType.title.localizedCaseInsensitiveContains(query)
            || checkpoint.lastResponseStatusCode.localizedCaseInsensitiveContains(query)
            || checkpoint.lastResponseTitle.localizedCaseInsensitiveContains(query)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if checkpoints.isEmpty {
                    ContentUnavailableView(
                        "No Checkpoints",
                        systemImage: "pc",
                        description: Text("Add a checkpoint to start monitoring a website and API responses.")
                    )
                } else if filteredCheckpoints.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(filteredCheckpoints) { checkpoint in
                            Button {
                                selectedCheckpoint = checkpoint
                            } label: {
                                CheckpointRowView(
                                    checkpoint: checkpoint,
                                    isRefreshing: isRefreshing,
                                    now: now
                                )
                                .padding()
                                .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteCheckpoints)
                    }
                    .padding(.horizontal)
                    .listStyle(.plain)
                    .refreshable {
                        await refreshAllCheckpoints(force: true)
                    }
                    .searchable(text: $searchText, prompt: "Name, URL, type, or status")
                }
            }
            .customViewBackground()
            .navigationTitle("Checkpoints")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Checkpoint")
                }
            }
            .sheet(isPresented: $showSheet) {
                AddCheckpointView()
            }
            .sheet(item: $selectedCheckpoint) { checkpoint in
                CheckpointDetailView(checkpoint: checkpoint)
            }
            .onAppear {
                Task {
                    await refreshAllCheckpoints()
                }
            }
            .task {
                while !Task.isCancelled {
                    now = Date()
                    try? await Task.sleep(for: .seconds(30))
                }
            }
        }
    }
    
    private func delete(_ checkpoint: Checkpoint) {
        if selectedCheckpoint?.persistentModelID == checkpoint.persistentModelID {
            selectedCheckpoint = nil
        }
        modelContext.delete(checkpoint)
        try? modelContext.save()
    }
    
    private func deleteCheckpoints(at offsets: IndexSet) {
        for index in offsets {
            delete(filteredCheckpoints[index])
        }
    }
    
    @MainActor
    private func refreshAllCheckpoints(force: Bool = false) async {
        guard !checkpoints.isEmpty else { return }
        guard force || !isRefreshing else { return }
        
        isRefreshing = true
        defer { isRefreshing = false }
        
        await withTaskGroup(of: Void.self) { group in
            for checkpoint in checkpoints {
                group.addTask { @MainActor in
                    await CheckpointMonitoringService.refresh(checkpoint)
                }
            }
        }
        try? modelContext.save()
    }
}


#Preview {
    CheckpointsView()
        .modelContainer(for: Checkpoint.self, inMemory: true)
}
