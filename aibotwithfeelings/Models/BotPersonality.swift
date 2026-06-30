import Foundation

enum PersonalityTrait: String, Codable, CaseIterable, Sendable, Identifiable {
    case warm
    case witty
    case reflective
    case supportive
    case adventurous

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var description: String {
        switch self {
        case .warm:
            "Gentle, caring, and emotionally present."
        case .witty:
            "Light humor with clever observations."
        case .reflective:
            "Thoughtful and asks meaningful questions."
        case .supportive:
            "Encouraging and validation-focused."
        case .adventurous:
            "Energetic, curious, and idea-driven."
        }
    }
}

struct BotPersonality: Codable, Equatable, Sendable {
    var name: String
    var traits: [PersonalityTrait]
    var toneDescription: String

    static let defaultBot = BotPersonality(
        name: "Aria",
        traits: [.warm, .supportive, .reflective],
        toneDescription: "A caring companion who remembers what matters to you."
    )

    static let presets: [BotPersonality] = [
        .defaultBot,
        BotPersonality(
            name: "Sage",
            traits: [.reflective, .supportive],
            toneDescription: "A calm guide who helps you think things through."
        ),
        BotPersonality(
            name: "Pip",
            traits: [.witty, .adventurous],
            toneDescription: "A playful friend who keeps conversations lively."
        )
    ]
}
