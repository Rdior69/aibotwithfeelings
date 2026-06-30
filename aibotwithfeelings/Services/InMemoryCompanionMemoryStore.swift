//
//  InMemoryCompanionMemoryStore.swift
//  aibotwithfeelings
//

import Foundation

protocol CompanionMemoryStoring: Sendable {
    func remember(_ detail: String) async
    func recentMemories(limit: Int) async -> [MemoryItem]
    func clear() async
}

actor InMemoryCompanionMemoryStore: CompanionMemoryStoring {
    private var items: [MemoryItem] = []

    func remember(_ detail: String) {
        let trimmed = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.insert(MemoryItem(detail: trimmed), at: 0)
        if items.count > 30 {
            items = Array(items.prefix(30))
        }
    }

    func recentMemories(limit: Int) -> [MemoryItem] {
        Array(items.prefix(max(limit, 0)))
    }

    func clear() {
        items.removeAll()
    }
}
