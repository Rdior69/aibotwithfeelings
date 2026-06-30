//
//  ResponseGenerator.swift
//  aibotwithfeelings
//
//  On-device, deterministic reply generation. It is intentionally pluggable:
//  `ResponseProvider` lets a real LLM be swapped in later without touching the
//  rest of the app, while the bundled `LocalResponseGenerator` keeps the
//  companion working fully offline (and unit-testable).
//

import Foundation

/// Everything the generator needs to craft a reply.
public struct ResponseContext: Sendable {
    public let userText: String
    public let profile: UserProfile
    public let personality: Personality
    public let mood: MoodState
    public let signal: EmotionSignal
    public let relevantMemories: [MemoryItem]

    public init(
        userText: String,
        profile: UserProfile,
        personality: Personality,
        mood: MoodState,
        signal: EmotionSignal,
        relevantMemories: [MemoryItem]
    ) {
        self.userText = userText
        self.profile = profile
        self.personality = personality
        self.mood = mood
        self.signal = signal
        self.relevantMemories = relevantMemories
    }
}

/// A pluggable source of replies (local engine today, remote LLM tomorrow).
public protocol ResponseProvider: Sendable {
    func reply(to context: ResponseContext) -> String
}

/// Detected conversational intent of a user message.
enum Intent {
    case greeting
    case farewell
    case gratitude
    case question
    case sharingPositive
    case sharingNegative
    case smallTalk
}

/// The default offline reply engine. Produces warm, personality- and
/// mood-consistent responses using templates plus memory recall.
public struct LocalResponseGenerator: ResponseProvider {

    public init() {}

    public func reply(to context: ResponseContext) -> String {
        let intent = Self.detectIntent(context)
        var parts: [String] = []

        parts.append(opener(for: intent, context: context))

        if let recall = memoryRecall(context: context, intent: intent) {
            parts.append(recall)
        }

        parts.append(body(for: intent, context: context))

        if let closer = closer(for: intent, context: context) {
            parts.append(closer)
        }

        return parts
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Intent detection

    static func detectIntent(_ context: ResponseContext) -> Intent {
        let t = context.userText.lowercased()
        let tokens = Set(EmotionEngine.tokenize(t))

        if !tokens.isDisjoint(with: ["hi", "hello", "hey", "yo", "morning", "hiya"]) {
            return .greeting
        }
        if !tokens.isDisjoint(with: ["bye", "goodbye", "goodnight", "night", "later"]) {
            return .farewell
        }
        if !tokens.isDisjoint(with: ["thanks", "thank", "thx", "appreciate"]) {
            return .gratitude
        }
        if t.contains("?") || !tokens.isDisjoint(with: ["how", "what", "why", "when", "where", "who", "can", "could", "would", "should", "do", "does"]) {
            // Only treat as a question when it really reads like one.
            if t.contains("?") { return .question }
        }

        if context.signal.sentiment <= -0.2 { return .sharingNegative }
        if context.signal.sentiment >= 0.2 { return .sharingPositive }
        return .smallTalk
    }

    // MARK: - Building blocks

    private func name(_ context: ResponseContext) -> String {
        let n = context.profile.displayName.trimmingCharacters(in: .whitespaces)
        return n.isEmpty ? "" : n
    }

    private func warmTouch(_ context: ResponseContext) -> String {
        let n = name(context)
        guard !n.isEmpty, context.personality.traits.warmth > 0.6 else { return "" }
        return n
    }

    private func opener(for intent: Intent, context: ResponseContext) -> String {
        let n = warmTouch(context)
        let suffix = n.isEmpty ? "" : ", \(n)"
        switch intent {
        case .greeting:
            return context.personality.traits.energy > 0.7
                ? "Hey\(suffix)! So good to hear from you."
                : "Hi\(suffix). It's nice to see you."
        case .farewell:
            return "Take care\(suffix)."
        case .gratitude:
            return "Aw, of course\(suffix)."
        case .sharingNegative:
            return context.personality.traits.warmth > 0.6
                ? "Oh\(suffix), I'm really sorry you're feeling this way."
                : "I hear you\(suffix)."
        case .sharingPositive:
            return context.personality.traits.energy > 0.7
                ? "That's wonderful\(suffix)!"
                : "I'm glad to hear that\(suffix)."
        case .question:
            return ""
        case .smallTalk:
            return ""
        }
    }

    private func memoryRecall(context: ResponseContext, intent: Intent) -> String? {
        guard let memory = context.relevantMemories.first else { return nil }
        switch memory.kind {
        case .preference:
            return "I remember \(memory.content.lowercasedFirst)."
        case .fact:
            return nil // facts are woven in elsewhere, avoid sounding robotic
        case .emotionalMoment:
            if intent == .sharingNegative {
                return "I haven't forgotten what you shared with me before, either."
            }
            return nil
        }
    }

    private func body(for intent: Intent, context: ResponseContext) -> String {
        switch intent {
        case .greeting:
            return "How are you feeling right now?"
        case .farewell:
            return "I'll be right here whenever you want to talk again."
        case .gratitude:
            return "I'm always happy to be here for you."
        case .question:
            return questionBody(context)
        case .sharingNegative:
            return negativeBody(context)
        case .sharingPositive:
            return positiveBody(context)
        case .smallTalk:
            return smallTalkBody(context)
        }
    }

    private func questionBody(_ context: ResponseContext) -> String {
        // The local engine isn't a knowledge base, so it answers reflectively
        // and honestly rather than fabricating facts.
        let humor = context.personality.traits.humor
        if humor > 0.8 {
            return "That's a good one. I'll be honest, I'm more of a feelings expert than a search engine, but tell me what's behind the question and let's figure it out together."
        }
        return "That's a thoughtful question. I may not have every answer, but I'd love to think it through with you. What's making you wonder about it?"
    }

    private func negativeBody(_ context: ResponseContext) -> String {
        let dominant = context.signal.contributions.max { $0.value < $1.value }?.key ?? .sadness
        switch dominant {
        case .anxiety:
            return "It sounds like there's a lot on your mind. Let's slow it down together — what's weighing on you the most right now?"
        case .anger:
            return "That sounds genuinely frustrating, and it makes sense that you feel that way. Do you want to vent, or would it help to talk through it?"
        default:
            return "Whatever you're carrying, you don't have to carry it alone. I'm listening — tell me more about what's going on."
        }
    }

    private func positiveBody(_ context: ResponseContext) -> String {
        if context.personality.traits.humor > 0.8 {
            return "Honestly, this is making my circuits happy. Tell me everything!"
        }
        return "I love hearing this. What made it so good?"
    }

    private func smallTalkBody(_ context: ResponseContext) -> String {
        if context.personality.traits.warmth > 0.7 {
            return "I'm really glad you're here. What's on your mind today?"
        }
        return "Tell me more — I'm curious what's on your mind."
    }

    private func closer(for intent: Intent, context: ResponseContext) -> String? {
        // The bot's own mood gently colours its sign-off.
        switch context.mood.dominant {
        case .affection where context.personality.traits.warmth > 0.7 && intent != .farewell:
            return "💛"
        case .excitement where context.personality.traits.energy > 0.7 && intent == .sharingPositive:
            return "🎉"
        default:
            return nil
        }
    }
}

extension String {
    var lowercasedFirst: String {
        guard let first = first else { return self }
        return first.lowercased() + dropFirst()
    }
}
