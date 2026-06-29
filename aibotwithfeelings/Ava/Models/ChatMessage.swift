import Foundation

enum MessageRole: String, Codable, Sendable {
    case user
    case ava
    case system
}

struct ChatMessage: Identifiable, Equatable, Sendable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    let toolsUsed: [String]

    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        toolsUsed: [String] = []
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.toolsUsed = toolsUsed
    }
}

enum AvaThinkingPhase: Equatable, Sendable {
    case idle
    case analyzing
    case gatheringExternalIntel(tools: [String])
    case synthesizing
    case failed(String)

    var displayText: String {
        switch self {
        case .idle:
            return ""
        case .analyzing:
            return "Reading between the lines..."
        case .gatheringExternalIntel(let tools):
            return "Pulling live intel: \(tools.joined(separator: ", "))"
        case .synthesizing:
            return "Connecting dots you didn't ask for..."
        case .failed(let message):
            return message
        }
    }
}
