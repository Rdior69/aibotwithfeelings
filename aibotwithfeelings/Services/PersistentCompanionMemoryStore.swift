//
//  PersistentCompanionMemoryStore.swift
//  aibotwithfeelings
//

import Foundation

actor PersistentCompanionMemoryStore: CompanionMemoryStoring {
    private let defaults: UserDefaults
    private let key: String
    private let maxItems: Int
    private var items: [MemoryItem]

    init(
        defaults: UserDefaults = .standard,
        key: String = "aibot.memories.v1",
        maxItems: Int = 30
    ) {
        self.defaults = defaults
        self.key = key
        self.maxItems = maxItems

        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode([MemoryItem].self, from: data) {
            self.items = decoded
        } else {
            self.items = []
        }
    }

    func remember(_ detail: String) {
        let trimmed = detail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.insert(MemoryItem(detail: trimmed), at: 0)
        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }
        persist()
    }

    func recentMemories(limit: Int) -> [MemoryItem] {
        Array(items.prefix(max(limit, 0)))
    }

    func clear() {
        items.removeAll()
        defaults.removeObject(forKey: key)
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: key)
    }
}
