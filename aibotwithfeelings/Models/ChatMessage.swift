import Foundation

enum MessageRole: String, Codable, Sendable {
    case user
    case assistant
    case system
}

enum Emotion: String, Codable, CaseIterable, Sendable, Identifiable {
    case joyful
    case calm
    case curious
    case empathetic
    case thoughtful
    case concerned
    case playful

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var symbolName: String {
        switch self {
        case .joyful: "sun.max.fill"
        case .calm: "leaf.fill"
        case .curious: "questionmark.circle.fill"
        case .empathetic: "heart.fill"
        case .thoughtful: "brain.head.profile"
        case .concerned: "cloud.rain.fill"
        case .playful: "sparkles"
        }
    }
}

struct ChatMessage: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let role: MessageRole
    let content: String
    let emotion: Emotion?
    let timestamp: Date

    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        emotion: Emotion? = nil,
        timestamp: Date = .now
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.emotion = emotion
        self.timestamp = timestamp
    }
}
