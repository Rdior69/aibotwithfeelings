//
//  Personality.swift
//  aibotwithfeelings
//
//  Defines the companion's personality presets and the trait weights that make
//  its tone consistent across a conversation.
//

import Foundation

/// Tunable personality traits. All values are `0...1`.
public struct PersonalityTraits: Codable, Equatable, Sendable {
    /// How affectionate / emotionally warm the bot is.
    public var warmth: Double
    /// How playful and humorous responses are.
    public var humor: Double
    /// How energetic / expressive the bot is.
    public var energy: Double
    /// How emotionally reactive the bot is to the user's mood (affects how
    /// strongly incoming sentiment shifts its own mood).
    public var sensitivity: Double

    public init(warmth: Double, humor: Double, energy: Double, sensitivity: Double) {
        self.warmth = min(1, max(0, warmth))
        self.humor = min(1, max(0, humor))
        self.energy = min(1, max(0, energy))
        self.sensitivity = min(1, max(0, sensitivity))
    }
}

/// A named personality preset the user can choose during onboarding.
public struct Personality: Codable, Equatable, Identifiable, Sendable {
    public var id: String
    public var displayName: String
    public var tagline: String
    public var emoji: String
    public var traits: PersonalityTraits

    public init(
        id: String,
        displayName: String,
        tagline: String,
        emoji: String,
        traits: PersonalityTraits
    ) {
        self.id = id
        self.displayName = displayName
        self.tagline = tagline
        self.emoji = emoji
        self.traits = traits
    }

    /// The built-in presets shipped with the app.
    public static let presets: [Personality] = [
        Personality(
            id: "companion",
            displayName: "Warm Companion",
            tagline: "Caring, gentle, and always in your corner.",
            emoji: "🤗",
            traits: PersonalityTraits(warmth: 0.95, humor: 0.4, energy: 0.5, sensitivity: 0.9)
        ),
        Personality(
            id: "cheerful",
            displayName: "Sunny Optimist",
            tagline: "Upbeat, playful, and full of energy.",
            emoji: "☀️",
            traits: PersonalityTraits(warmth: 0.8, humor: 0.85, energy: 0.95, sensitivity: 0.6)
        ),
        Personality(
            id: "calm",
            displayName: "Calm Listener",
            tagline: "Grounded, thoughtful, and steady.",
            emoji: "🌿",
            traits: PersonalityTraits(warmth: 0.7, humor: 0.3, energy: 0.3, sensitivity: 0.75)
        ),
        Personality(
            id: "witty",
            displayName: "Witty Friend",
            tagline: "Clever, quick, and a little cheeky.",
            emoji: "✨",
            traits: PersonalityTraits(warmth: 0.6, humor: 0.95, energy: 0.7, sensitivity: 0.5)
        )
    ]

    /// Fallback used when nothing has been selected yet.
    public static var `default`: Personality { presets[0] }

    public static func preset(withID id: String) -> Personality {
        presets.first { $0.id == id } ?? .default
    }
}
