//
//  MemoryStore.swift
//  aibotwithfeelings
//
//  The companion's long-term memory. Extracts durable facts / preferences from
//  user messages and retrieves relevant memories for later recall.
//

import Foundation

/// Stores and retrieves the companion's memories. This is a value-semantics
/// store; persistence is handled separately so it stays easy to test.
public struct MemoryStore: Codable, Equatable, Sendable {
    public private(set) var items: [MemoryItem]

    public init(items: [MemoryItem] = []) {
        self.items = items
    }

    /// Common English words ignored when computing keywords / relevance.
    static let stopWords: Set<String> = [
        "the", "a", "an", "and", "or", "but", "is", "am", "are", "was", "were",
        "i", "im", "i'm", "you", "me", "my", "your", "to", "of", "in", "on",
        "for", "it", "this", "that", "with", "so", "at", "be", "have", "has",
        "do", "did", "just", "really", "very", "feel", "feeling", "today",
        "like", "about", "we", "they", "he", "she", "as", "if", "then", "now"
    ]

    static func keywords(from text: String) -> [String] {
        EmotionEngine.tokenize(text)
            .filter { $0.count > 2 && !stopWords.contains($0) }
    }

    // MARK: - Writing

    /// Add a memory, deduplicating against near-identical existing content.
    public mutating func add(_ item: MemoryItem) {
        let normalized = item.content.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if items.contains(where: {
            $0.content.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == normalized
        }) {
            return
        }
        items.append(item)
    }

    /// Inspect a user message and extract any durable facts / preferences.
    /// Returns the newly added memories (empty if nothing notable was found).
    @discardableResult
    public mutating func learn(
        from text: String,
        sentiment: Double,
        now: Date = Date()
    ) -> [MemoryItem] {
        var learned: [MemoryItem] = []
        let lowered = text.lowercased()

        func capture(_ kind: MemoryKind, _ content: String, importance: Double) {
            let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.count > 1 else { return }
            let item = MemoryItem(
                kind: kind,
                content: trimmed,
                keywords: MemoryStore.keywords(from: trimmed),
                sentiment: sentiment,
                importance: importance,
                createdAt: now
            )
            let before = items.count
            add(item)
            if items.count > before { learned.append(item) }
        }

        // Name: "my name is X" / "call me X" / "i'm X" / "i am X"
        if let name = MemoryStore.firstMatch(in: lowered,
                                             patterns: ["my name is ", "call me ", "i am called "]) {
            capture(.fact, "User's name is \(name.capitalizedFirst)", importance: 1.0)
        }

        // Job: "i work as ...", "i'm a ...", "my job is ..."
        if let job = MemoryStore.firstMatch(in: lowered,
                                            patterns: ["i work as ", "my job is ", "i work at "]) {
            capture(.fact, "User works: \(job)", importance: 0.8)
        }

        // Preferences.
        if let liked = MemoryStore.firstMatch(in: lowered,
                                              patterns: ["i love ", "i really like ", "i like ", "i enjoy "]) {
            capture(.preference, "User likes \(liked)", importance: 0.7)
        }
        if let disliked = MemoryStore.firstMatch(in: lowered,
                                                 patterns: ["i hate ", "i don't like ", "i dont like ", "i can't stand "]) {
            capture(.preference, "User dislikes \(disliked)", importance: 0.7)
        }

        // Strong emotional moments worth remembering.
        if abs(sentiment) >= 0.6 {
            let mood = sentiment > 0 ? "felt good" : "was having a hard time"
            capture(.emotionalMoment,
                    "User \(mood): \"\(text.trimmedShort)\"",
                    importance: 0.5 + abs(sentiment) * 0.3)
        }

        return learned
    }

    // MARK: - Reading

    /// Return the memories most relevant to `text`, ranked by keyword overlap,
    /// importance, and recency. `limit` caps the result count.
    public func relevantMemories(
        to text: String,
        limit: Int = 3,
        now: Date = Date()
    ) -> [MemoryItem] {
        let queryKeywords = Set(MemoryStore.keywords(from: text))
        guard !items.isEmpty else { return [] }

        let scored: [(MemoryItem, Double)] = items.map { item in
            let overlap = Double(Set(item.keywords).intersection(queryKeywords).count)
            // Recency factor: newer memories score slightly higher.
            let ageDays = max(0, now.timeIntervalSince(item.createdAt) / 86_400)
            let recency = 1.0 / (1.0 + ageDays / 30.0)
            let score = overlap * 2.0 + item.importance + recency * 0.5
            return (item, overlap > 0 ? score : score * 0.01)
        }

        return scored
            .filter { $0.1 > 0.02 }
            .sorted { $0.1 > $1.1 }
            .prefix(limit)
            .map { $0.0 }
    }

    /// All facts known about the user, most important first.
    public var knownFacts: [MemoryItem] {
        items.filter { $0.kind == .fact }
            .sorted { $0.importance > $1.importance }
    }

    public mutating func remove(id: UUID) {
        items.removeAll { $0.id == id }
    }

    public mutating func clear() {
        items.removeAll()
    }

    // MARK: - Helpers

    /// Returns the text following the first matching prefix pattern, trimmed to
    /// a single clause (up to the next sentence-ending punctuation).
    static func firstMatch(in text: String, patterns: [String]) -> String? {
        for pattern in patterns {
            guard let range = text.range(of: pattern) else { continue }
            let remainder = String(text[range.upperBound...])
            let clause = remainder.prefix { $0 != "." && $0 != "," && $0 != "!" && $0 != "?" && $0 != "\n" }
            var result = clause.trimmingCharacters(in: .whitespaces)
            // Stop at connectives so we capture a single clause rather than the
            // rest of a run-on sentence (e.g. "Sam and I love astronomy").
            for connective in [" and ", " but ", " because ", " so ", " then "] {
                if let r = result.range(of: connective) {
                    result = String(result[..<r.lowerBound])
                }
            }
            result = result.trimmingCharacters(in: .whitespaces)
            if !result.isEmpty { return result }
        }
        return nil
    }
}

extension String {
    var capitalizedFirst: String {
        guard let first = first else { return self }
        return first.uppercased() + dropFirst()
    }

    /// A short, single-line excerpt suitable for storing inside a memory.
    var trimmedShort: String {
        let collapsed = replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespaces)
        if collapsed.count <= 80 { return collapsed }
        return String(collapsed.prefix(80)) + "…"
    }
}
