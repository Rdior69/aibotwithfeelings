import Foundation

enum MemoryCategory: String, Codable, CaseIterable, Sendable {
    case preference
    case lifeEvent
    case feeling
    case goal
    case relationship

    var displayName: String {
        switch self {
        case .preference: "Preference"
        case .lifeEvent: "Life Event"
        case .feeling: "Feeling"
        case .goal: "Goal"
        case .relationship: "Relationship"
        }
    }
}

struct EmotionalMemory: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var summary: String
    var category: MemoryCategory
    var emotionalWeight: Double
    var createdAt: Date
    var lastReferencedAt: Date

    init(
        id: UUID = UUID(),
        summary: String,
        category: MemoryCategory,
        emotionalWeight: Double = 0.5,
        createdAt: Date = .now,
        lastReferencedAt: Date = .now
    ) {
        self.id = id
        self.summary = summary
        self.category = category
        self.emotionalWeight = min(max(emotionalWeight, 0), 1)
        self.createdAt = createdAt
        self.lastReferencedAt = lastReferencedAt
    }
}
