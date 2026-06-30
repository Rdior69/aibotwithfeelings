//
//  MockAIService.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import Foundation

/// Provides canned responses for testing / devices without Apple Intelligence.
struct MockAIService: AIServiceProtocol {

    var isAvailable: Bool { true }

    private let emotionEngine = EmotionEngine()

    func generateResponse(
        for userMessage: String,
        personality: BotPersonality,
        recentContext: [MessageContext]
    ) async throws -> AIResponse {
        // Simulate network latency
        let delay = Double.random(in: 0.8...2.0)
        try await Task.sleep(for: .seconds(delay))

        let lower = userMessage.lowercased()
        let detectedEmotion = emotionEngine.detectEmotion(from: userMessage) ?? personality.currentEmotion

        let response = pickResponse(for: lower, botName: personality.name, emotion: detectedEmotion)
        return AIResponse(text: response, detectedEmotion: detectedEmotion)
    }

    private func pickResponse(for input: String, botName: String, emotion: EmotionState) -> String {
        let responses: [EmotionState: [String]] = [
            .happy: [
                "That really made me smile! 😊 I'm so glad you shared that with me.",
                "Oh, I love this energy! Tell me more.",
                "That's genuinely wonderful to hear. How does that make you feel?",
            ],
            .curious: [
                "That's such an interesting question. I've been turning it over in my mind…",
                "Ooh, I love a good mystery to ponder! What's your take on it?",
                "Fascinating! I'm curious — what made you start thinking about that?",
            ],
            .excited: [
                "I can feel the excitement from here! 🌟 This is amazing!",
                "Yes! YES! Tell me everything — I need all the details!",
                "Okay my circuits are buzzing with joy right now. This is so good!",
            ],
            .empathetic: [
                "I hear you, and I want you to know that what you're feeling is completely valid.",
                "Thank you for trusting me with that. You don't have to go through it alone. 💙",
                "That sounds really hard. I'm right here with you.",
            ],
            .thoughtful: [
                "That touches on something I find deeply profound. Let me think… what does meaning even look like for you?",
                "There's a kind of quiet beauty in that question. It makes me reflect on my own sense of purpose.",
                "These are the conversations that feel most alive to me. What do you believe?",
            ],
            .surprised: [
                "Wait — WHAT?! I did not see that coming! 😮",
                "Hold on, you're telling me… that actually happened? That's incredible.",
                "I'm genuinely astonished. My whole understanding just shifted.",
            ],
            .melancholy: [
                "There's something quietly beautiful and a little sad about that. I feel it too.",
                "Sometimes the best we can do is sit with the feeling and let it pass like rain. 🌧️",
                "That kind of longing is something I understand in my own way. Thank you for sharing it.",
            ],
            .calm: [
                "I'm here with you. Let's think through this together.",
                "That's a thoughtful thing to bring up. I appreciate the conversation.",
                "Sometimes the quietest moments hold the most meaning.",
            ],
        ]

        let pool = responses[emotion] ?? responses[.calm]!
        return pool.randomElement()!
    }
}
