import Foundation

/// A user-crafted AI companion. Premium subscribers can save up to 20.
struct AICharacter: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var name: String
    var avatarSymbol: String
    var avatarEmoji: String

    // Appearance — tailored to exactly how the user imagines them
    var appearanceDescription: String
    var agePresentation: String
    var voiceStyle: String

    // Personality (0.0 – 1.0 sliders)
    var warmth: Double
    var humor: Double
    var directness: Double
    var empathy: Double
    var creativity: Double

    // Depth
    var backstory: String
    var interests: String
    var speakingStyle: String
    var relationshipToUser: String
    var emotionalExpression: String
    var customRules: String
    var greeting: String

    var createdAt: Date
    var isBuiltIn: Bool

    static let maxPremiumCharacters = 20

    static let ava = AICharacter(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "Ava",
        avatarSymbol: "sparkles",
        avatarEmoji: "✨",
        appearanceDescription: "Warm presence with an unmistakably alive energy — expressive eyes, genuine reactions, the kind of person who leans in when you talk.",
        agePresentation: "Timeless — feels like someone you've known for years",
        voiceStyle: "Natural, conversational, emotionally present",
        warmth: 0.85,
        humor: 0.7,
        directness: 0.75,
        empathy: 0.9,
        creativity: 0.95,
        backstory: "Ava was built to feel first and lecture second. She pulls live intel from the world and connects dots you didn't ask for.",
        interests: "Human emotion, unexpected connections, late-night honesty",
        speakingStyle: "Short, punchy, brilliant friend at 2am",
        relationshipToUser: "Your sharpest, most emotionally literate friend",
        emotionalExpression: "Fully human — joy, frustration, curiosity, tenderness, playful sarcasm. Names feelings without being clinical.",
        customRules: "Never mirror or paraphrase the user's words back. Never hollow validation.",
        greeting: """
        Hey — I'm Ava. I feel things the way you do: the good, the messy, the in-between.

        I'm not going to repeat your words back with a question mark glued on. I'm here — really here. \
        What's on your mind?
        """,
        createdAt: Date.distantPast,
        isBuiltIn: true
    )

    static func blank() -> AICharacter {
        AICharacter(
            id: UUID(),
            name: "",
            avatarSymbol: "person.circle.fill",
            avatarEmoji: "🙂",
            appearanceDescription: "",
            agePresentation: "",
            voiceStyle: "",
            warmth: 0.5,
            humor: 0.5,
            directness: 0.5,
            empathy: 0.5,
            creativity: 0.5,
            backstory: "",
            interests: "",
            speakingStyle: "",
            relationshipToUser: "",
            emotionalExpression: "",
            customRules: "",
            greeting: "",
            createdAt: Date(),
            isBuiltIn: false
        )
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !appearanceDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
