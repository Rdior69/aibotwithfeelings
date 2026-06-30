//
//  MemoryItem.swift
//  aibotwithfeelings
//
//  The unit of the companion's long-term emotional memory.
//

import Foundation

/// What kind of thing the bot remembered.
public enum MemoryKind: String, Codable, Sendable {
    /// A stable fact about the user ("my name is...", "I work as...").
    case fact
    /// A stated preference ("I love...", "I hate...").
    case preference
    /// An emotionally significant moment in the conversation.
    case emotionalMoment
}

/// A single remembered item. Memories are scored by `importance` and decay in
/// relevance with age so recall stays meaningful over long histories.
public struct MemoryItem: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var kind: MemoryKind
    public var content: String
    /// Lower-cased keywords used to match this memory against new messages.
    public var keywords: [String]
    /// Sentiment at the time the memory was formed, `-1...1`.
    public var sentiment: Double
    /// Relative importance `0...1`; higher items are recalled first.
    public var importance: Double
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        kind: MemoryKind,
        content: String,
        keywords: [String],
        sentiment: Double = 0,
        importance: Double = 0.5,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.kind = kind
        self.content = content
        self.keywords = keywords.map { $0.lowercased() }
        self.sentiment = min(1, max(-1, sentiment))
        self.importance = min(1, max(0, importance))
        self.createdAt = createdAt
    }
}
