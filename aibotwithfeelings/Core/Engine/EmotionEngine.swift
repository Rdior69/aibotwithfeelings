//
//  EmotionEngine.swift
//  aibotwithfeelings
//
//  Deterministic, on-device sentiment + emotion analysis. No network required,
//  which keeps the companion private and fully unit-testable.
//

import Foundation

/// The result of analysing a piece of text.
public struct EmotionSignal: Equatable, Sendable {
    /// Detected emotion contributions, `0...1` per emotion.
    public var contributions: [EmotionKind: Double]
    /// Net sentiment of the text, `-1...1`.
    public var sentiment: Double

    public init(contributions: [EmotionKind: Double], sentiment: Double) {
        self.contributions = contributions
        self.sentiment = sentiment
    }

    public static let empty = EmotionSignal(contributions: [:], sentiment: 0)
}

/// Analyses user text and evolves the companion's mood over time.
public struct EmotionEngine: Sendable {

    public init() {}

    /// Keyword → emotion weight lexicon. Intentionally compact but covers the
    /// most common emotional vocabulary in casual conversation.
    static let lexicon: [EmotionKind: [String]] = [
        .joy: ["happy", "glad", "great", "good", "awesome", "wonderful", "love",
               "joy", "yay", "fantastic", "amazing", "delighted", "pleased",
               "grateful", "thankful", "smile", "fun", "enjoy", "win", "won"],
        .affection: ["love", "adore", "care", "miss", "sweet", "dear", "hug",
                     "appreciate", "cherish", "fond", "friend", "together"],
        .excitement: ["excited", "can't wait", "cant wait", "thrilled", "pumped",
                      "stoked", "wow", "incredible", "epic", "celebrate"],
        .calm: ["calm", "relaxed", "peaceful", "fine", "okay", "ok", "chill",
                "rested", "content", "serene", "quiet"],
        .sadness: ["sad", "down", "unhappy", "depressed", "lonely", "alone",
                   "cry", "crying", "hurt", "heartbroken", "miserable", "blue",
                   "tired", "exhausted", "lost", "empty", "grief", "disappointed"],
        .anxiety: ["anxious", "worried", "nervous", "scared", "afraid", "fear",
                   "stress", "stressed", "panic", "overwhelmed", "tense",
                   "uneasy", "dread", "worry"],
        .anger: ["angry", "mad", "furious", "annoyed", "frustrated", "hate",
                 "irritated", "upset", "rage", "pissed", "resent", "unfair"]
    ]

    static let negations: Set<String> = ["not", "no", "never", "don't", "dont",
                                         "isn't", "isnt", "aren't", "arent",
                                         "wasn't", "wasnt", "can't", "cant",
                                         "without", "hardly", "barely"]

    static let intensifiers: Set<String> = ["very", "really", "so", "extremely",
                                            "incredibly", "super", "totally",
                                            "absolutely", "deeply"]

    /// Tokenises text into lower-cased word tokens.
    static func tokenize(_ text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
    }

    /// Analyse a message and return its emotional signal.
    public func analyze(_ text: String) -> EmotionSignal {
        let tokens = EmotionEngine.tokenize(text)
        guard !tokens.isEmpty else { return .empty }

        var contributions: [EmotionKind: Double] = [:]

        for (index, token) in tokens.enumerated() {
            // Look at the preceding two tokens for negation / intensification.
            let window = tokens[max(0, index - 2)..<index]
            let negated = window.contains { EmotionEngine.negations.contains($0) }
            let intensified = window.contains { EmotionEngine.intensifiers.contains($0) }
            let weight = intensified ? 0.5 : 0.3

            for (kind, words) in EmotionEngine.lexicon where words.contains(token) {
                if negated {
                    // Negating a positive emotion nudges toward sadness instead
                    // of simply cancelling, e.g. "not happy".
                    if kind.isPositive {
                        contributions[.sadness, default: 0] += weight * 0.6
                    }
                } else {
                    contributions[kind, default: 0] += weight
                }
            }
        }

        // Punctuation-based excitement boost.
        let exclamations = text.filter { $0 == "!" }.count
        if exclamations > 0 {
            contributions[.excitement, default: 0] += min(0.4, Double(exclamations) * 0.15)
        }

        // Clamp contributions.
        for (kind, value) in contributions {
            contributions[kind] = min(1.0, value)
        }

        var sentiment = 0.0
        for (kind, value) in contributions {
            sentiment += kind.isPositive ? value : -value
        }
        sentiment = min(1.0, max(-1.0, sentiment))

        return EmotionSignal(contributions: contributions, sentiment: sentiment)
    }

    /// Evolve a mood given a new signal and the bot's emotional sensitivity.
    ///
    /// The mood first decays toward baseline, then absorbs the new signal scaled
    /// by `sensitivity`. This produces gradual, believable mood drift rather
    /// than abrupt flips.
    public func updatedMood(
        from current: MoodState,
        applying signal: EmotionSignal,
        sensitivity: Double,
        decay: Double = 0.25
    ) -> MoodState {
        var mood = current.decayed(by: decay)
        let reactivity = 0.4 + 0.6 * min(1, max(0, sensitivity))
        for (kind, value) in signal.contributions {
            mood = mood.adjusting(kind, by: value * reactivity)
        }
        return mood
    }
}
