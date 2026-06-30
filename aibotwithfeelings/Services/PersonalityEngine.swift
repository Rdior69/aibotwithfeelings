import Foundation

struct PersonalityResponse: Sendable {
    let content: String
    let emotion: Emotion
    let extractedMemories: [EmotionalMemory]
    let referencedMemoryIDs: [UUID]
}

enum PersonalityEngine {
    static func greeting(for profile: UserProfile) -> PersonalityResponse {
        let name = profile.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let botName = profile.preferredBot.name

        let content: String
        if name.isEmpty {
            content = "Hi, I'm \(botName). I'm glad you're here. What's on your mind today?"
        } else {
            content = "Hi \(name), it's \(botName). I'm really glad to see you. How are you feeling right now?"
        }

        return PersonalityResponse(
            content: content,
            emotion: .empathetic,
            extractedMemories: [],
            referencedMemoryIDs: []
        )
    }

    static func respond(
        to userMessage: String,
        profile: UserProfile,
        memories: [EmotionalMemory],
        recentMessages: [ChatMessage]
    ) -> PersonalityResponse {
        let lowercased = userMessage.lowercased()
        let emotion = detectEmotion(in: lowercased)
        let extracted = extractMemories(from: userMessage)
        let relevant = relevantMemories(for: userMessage, from: memories)
        let content = composeReply(
            userMessage: userMessage,
            profile: profile,
            emotion: emotion,
            relevantMemories: relevant,
            recentMessages: recentMessages
        )

        return PersonalityResponse(
            content: content,
            emotion: emotion,
            extractedMemories: extracted,
            referencedMemoryIDs: relevant.map(\.id)
        )
    }

    private static func detectEmotion(in text: String) -> Emotion {
        if text.contains("excited") || text.contains("happy") || text.contains("great") {
            return .joyful
        }
        if text.contains("sad") || text.contains("lonely") || text.contains("anxious") || text.contains("worried") {
            return .empathetic
        }
        if text.contains("why") || text.contains("how") || text.contains("?") {
            return .curious
        }
        if text.contains("fun") || text.contains("lol") || text.contains("haha") {
            return .playful
        }
        if text.contains("stressed") || text.contains("overwhelmed") {
            return .concerned
        }
        return .thoughtful
    }

    private static func extractMemories(from text: String) -> [EmotionalMemory] {
        var memories: [EmotionalMemory] = []
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 12 else { return memories }

        if trimmed.lowercased().contains("i love") || trimmed.lowercased().contains("i like") {
            memories.append(EmotionalMemory(summary: trimmed, category: .preference, emotionalWeight: 0.6))
        }

        if trimmed.lowercased().contains("i feel") {
            memories.append(EmotionalMemory(summary: trimmed, category: .feeling, emotionalWeight: 0.75))
        }

        if trimmed.lowercased().contains("my goal") || trimmed.lowercased().contains("i want to") {
            memories.append(EmotionalMemory(summary: trimmed, category: .goal, emotionalWeight: 0.7))
        }

        if trimmed.lowercased().contains("my ") && (
            trimmed.lowercased().contains("mom") ||
            trimmed.lowercased().contains("dad") ||
            trimmed.lowercased().contains("partner") ||
            trimmed.lowercased().contains("friend")
        ) {
            memories.append(EmotionalMemory(summary: trimmed, category: .relationship, emotionalWeight: 0.65))
        }

        return memories
    }

    private static func relevantMemories(for text: String, from memories: [EmotionalMemory]) -> [EmotionalMemory] {
        let tokens = Set(
            text.lowercased()
                .split { !$0.isLetter }
                .filter { $0.count > 3 }
        )

        return memories
            .sorted { $0.emotionalWeight > $1.emotionalWeight }
            .filter { memory in
                let memoryTokens = Set(
                    memory.summary.lowercased()
                        .split { !$0.isLetter }
                        .filter { $0.count > 3 }
                )
                return !tokens.isDisjoint(with: memoryTokens)
            }
            .prefix(2)
            .map { $0 }
    }

    private static func composeReply(
        userMessage: String,
        profile: UserProfile,
        emotion: Emotion,
        relevantMemories: [EmotionalMemory],
        recentMessages: [ChatMessage]
    ) -> String {
        let botName = profile.preferredBot.name
        let traits = profile.preferredBot.traits
        var parts: [String] = []

        let empathyOpeners: [String]
        switch emotion {
        case .joyful:
            empathyOpeners = [
                "I love hearing that energy from you.",
                "That sounds like a bright moment.",
                "Your excitement comes through clearly."
            ]
        case .empathetic, .concerned:
            empathyOpeners = [
                "Thank you for trusting me with that.",
                "That sounds like a lot to carry.",
                "I'm sitting with you in this."
            ]
        case .curious:
            empathyOpeners = [
                "That's a meaningful question.",
                "I'm glad you asked that.",
                "Let's explore that together."
            ]
        case .playful:
            empathyOpeners = [
                "Ha — I appreciate the lightness.",
                "You're fun to talk with.",
                "I like this playful vibe."
            ]
        default:
            empathyOpeners = [
                "I'm listening.",
                "Thanks for sharing that with me.",
                "I want to understand this with you."
            ]
        }

        parts.append("\(empathyOpeners.randomElement() ?? "I'm listening.")")

        if let memory = relevantMemories.first {
            parts.append("I remember you mentioned \(memory.summary.lowercased()) — that still matters to me.")
        }

        if traits.contains(.reflective) {
            parts.append("What part of this feels most important to you right now?")
        } else if traits.contains(.supportive) {
            parts.append("You don't have to figure this out alone.")
        } else if traits.contains(.witty) {
            parts.append("If this were a movie, we'd be in the thoughtful montage scene.")
        } else if traits.contains(.adventurous) {
            parts.append("Maybe there's a small next step we could imagine together.")
        } else {
            parts.append("Tell me more about what that means for you.")
        }

        if recentMessages.filter({ $0.role == .user }).count <= 1 {
            parts.append("I'm \(botName), and I'll do my best to remember what matters to you.")
        }

        if userMessage.count < 8 {
            parts.append("Even a few words is enough — I'm here.")
        }

        return parts.joined(separator: " ")
    }
}
