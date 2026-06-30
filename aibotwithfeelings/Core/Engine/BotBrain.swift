//
//  BotBrain.swift
//  aibotwithfeelings
//
//  Orchestrates a single conversational turn: safety → memory learning →
//  emotion update → memory recall → response generation. Pure logic, no UI, so
//  the whole pipeline is unit-testable.
//

import Foundation

/// The full result of processing one user message.
public struct TurnResult: Sendable {
    /// The bot's reply message.
    public let reply: ChatMessage
    /// The bot's mood after this turn.
    public let updatedMood: MoodState
    /// The memory store after learning from this turn.
    public let updatedMemory: MemoryStore
    /// Whether a safety override was triggered.
    public let safety: SafetyCategory
    /// Memories newly learned during this turn.
    public let learnedMemories: [MemoryItem]

    public init(
        reply: ChatMessage,
        updatedMood: MoodState,
        updatedMemory: MemoryStore,
        safety: SafetyCategory,
        learnedMemories: [MemoryItem]
    ) {
        self.reply = reply
        self.updatedMood = updatedMood
        self.updatedMemory = updatedMemory
        self.safety = safety
        self.learnedMemories = learnedMemories
    }
}

/// The companion's reasoning core. Stateless: callers pass in current state and
/// receive the next state, which keeps it deterministic and easy to test.
public struct BotBrain: Sendable {
    let emotionEngine: EmotionEngine
    let safetyGuard: SafetyGuard
    let responder: ResponseProvider

    public init(
        emotionEngine: EmotionEngine = EmotionEngine(),
        safetyGuard: SafetyGuard = SafetyGuard(),
        responder: ResponseProvider = LocalResponseGenerator()
    ) {
        self.emotionEngine = emotionEngine
        self.safetyGuard = safetyGuard
        self.responder = responder
    }

    /// Process one user message and return the next state + reply.
    public func process(
        userText: String,
        profile: UserProfile,
        mood: MoodState,
        memory: MemoryStore,
        now: Date = Date()
    ) -> TurnResult {
        let personality = profile.personality
        let signal = emotionEngine.analyze(userText)

        // 1. Safety always comes first.
        let assessment = safetyGuard.assess(userText)
        if let override = assessment.overrideResponse {
            // On a crisis the bot becomes gently calm and concerned rather than
            // cheerful, but we don't let it spiral negatively.
            let safeMood = mood.decayed(by: 0.3).adjusting(.calm, by: 0.3)
            let reply = ChatMessage(
                sender: .bot,
                text: override,
                timestamp: now,
                moodEmoji: EmotionKind.calm.emoji
            )
            return TurnResult(
                reply: reply,
                updatedMood: safeMood,
                updatedMemory: memory,
                safety: assessment.category,
                learnedMemories: []
            )
        }

        // 2. Learn durable facts / emotional moments.
        var updatedMemory = memory
        let learned = updatedMemory.learn(from: userText, sentiment: signal.sentiment, now: now)

        // 3. Update mood based on what the user expressed.
        let updatedMood = emotionEngine.updatedMood(
            from: mood,
            applying: signal,
            sensitivity: personality.traits.sensitivity
        )

        // 4. Recall relevant memories for context.
        let recalled = updatedMemory.relevantMemories(to: userText, limit: 3, now: now)

        // 5. Generate the reply.
        let context = ResponseContext(
            userText: userText,
            profile: profile,
            personality: personality,
            mood: updatedMood,
            signal: signal,
            relevantMemories: recalled
        )
        let replyText = responder.reply(to: context)
        let reply = ChatMessage(
            sender: .bot,
            text: replyText,
            timestamp: now,
            moodEmoji: updatedMood.dominant.emoji
        )

        return TurnResult(
            reply: reply,
            updatedMood: updatedMood,
            updatedMemory: updatedMemory,
            safety: assessment.category,
            learnedMemories: learned
        )
    }
}
