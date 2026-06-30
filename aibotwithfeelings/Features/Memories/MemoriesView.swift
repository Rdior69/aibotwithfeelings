//
//  MemoriesView.swift
//  aibotwithfeelings
//
//  Transparency + control over what the companion remembers. Users can review
//  and delete individual memories or clear everything (privacy first).
//

#if canImport(SwiftUI)
import SwiftUI

struct MemoriesView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showClearConfirm = false

    private var grouped: [(MemoryKind, [MemoryItem])] {
        let order: [MemoryKind] = [.fact, .preference, .emotionalMoment]
        return order.compactMap { kind in
            let items = appState.memory.items
                .filter { $0.kind == kind }
                .sorted { $0.createdAt > $1.createdAt }
            return items.isEmpty ? nil : (kind, items)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if appState.memory.items.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(grouped, id: \.0) { kind, items in
                            Section(header: Text(title(for: kind))) {
                                ForEach(items) { item in
                                    MemoryRow(item: item)
                                }
                                .onDelete { offsets in
                                    for index in offsets {
                                        appState.deleteMemory(id: items[index].id)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("What I Remember")
            .toolbar {
                if !appState.memory.items.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear", role: .destructive) { showClearConfirm = true }
                    }
                }
            }
            .confirmationDialog(
                "Forget everything?",
                isPresented: $showClearConfirm,
                titleVisibility: .visible
            ) {
                Button("Forget all memories", role: .destructive) {
                    appState.clearMemories()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("I'll forget every fact and moment you've shared. This can't be undone.")
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No memories yet",
            systemImage: "brain.head.profile",
            description: Text("As we chat, I'll remember the things that matter to you. They'll show up here.")
        )
    }

    private func title(for kind: MemoryKind) -> String {
        switch kind {
        case .fact: return "About You"
        case .preference: return "Your Likes & Dislikes"
        case .emotionalMoment: return "Moments We Shared"
        }
    }
}

struct MemoryRow: View {
    let item: MemoryItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.tint)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.content)
                    .font(.body)
                Text(item.createdAt, format: .dateTime.month().day().year())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var icon: String {
        switch item.kind {
        case .fact: return "person.text.rectangle"
        case .preference: return "heart"
        case .emotionalMoment: return "sparkles"
        }
    }
}

#Preview {
    MemoriesView()
        .environmentObject(AppState())
}
#endif
