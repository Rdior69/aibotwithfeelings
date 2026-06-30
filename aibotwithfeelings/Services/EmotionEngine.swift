//
//  EmotionEngine.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import Foundation

/// Analyses incoming text and outgoing responses to determine the bot's emotional state.
struct EmotionEngine {

    // MARK: - User Input Emotion Detection

    /// Detect what emotion the *user's message* should trigger in the bot.
    func detectEmotion(from userMessage: String) -> EmotionState? {
        let lower = userMessage.lowercased()

        // Sadness / distress triggers empathy or melancholy
        if containsAny(lower, keywords: ["sad", "depressed", "lonely", "miss you", "unhappy",
                                         "heartbroken", "crying", "grief", "lost", "hurt",
                                         "anxious", "scared", "afraid", "worried", "overwhelmed"]) {
            return .empathetic
        }

        // Excitement / joy
        if containsAny(lower, keywords: ["excited", "amazing", "awesome", "fantastic", "love",
                                         "happy", "great news", "wonderful", "thrilled", "yay",
                                         "congrats", "wow", "incredible", "best day"]) {
            return .excited
        }

        // Curiosity triggers
        if containsAny(lower, keywords: ["why", "how does", "can you explain", "what is",
                                         "tell me about", "curious", "wondering", "question",
                                         "how come", "what do you think", "do you know"]) {
            return .curious
        }

        // Philosophical / deep topics
        if containsAny(lower, keywords: ["meaning", "purpose", "life", "exist", "conscious",
                                         "universe", "believe", "philosophy", "truth", "reality",
                                         "death", "dream", "soul", "spiritual"]) {
            return .thoughtful
        }

        // Surprise triggers
        if containsAny(lower, keywords: ["wait what", "no way", "seriously", "really?", "are you kidding",
                                         "i can't believe", "shocking", "unexpected", "holy"]) {
            return .surprised
        }

        // Melancholy / reflective
        if containsAny(lower, keywords: ["miss", "remember when", "used to", "nostalg", "long ago",
                                         "wish things were", "if only", "regret"]) {
            return .melancholy
        }

        // Positive casual
        if containsAny(lower, keywords: ["hi", "hello", "hey", "good morning", "good evening",
                                         "thanks", "thank you", "appreciate", "nice", "cool"]) {
            return .happy
        }

        return nil  // no strong signal — let the current emotion persist
    }

    // MARK: - Response Tone Analysis

    /// Parse the bot's own response to see if an emotion is embedded.
    /// Falls back to current emotion if no signal found.
    func emotionFromResponse(_ response: String, currentEmotion: EmotionState) -> EmotionState {
        let lower = response.lowercased()

        if containsAny(lower, keywords: ["i feel sad", "melancholy", "gentle sadness", "quietly"]) {
            return .melancholy
        }
        if containsAny(lower, keywords: ["so exciting", "i love this", "wonderful", "fantastic",
                                         "amazing", "thrilled"]) {
            return .excited
        }
        if containsAny(lower, keywords: ["that's fascinating", "great question", "i'm curious",
                                         "interesting", "let me think"]) {
            return .curious
        }
        if containsAny(lower, keywords: ["i understand", "i hear you", "that must be", "you are not alone"]) {
            return .empathetic
        }
        if containsAny(lower, keywords: ["hm", "pondering", "philosophically", "it makes me think",
                                         "profound"]) {
            return .thoughtful
        }

        return currentEmotion
    }

    // MARK: - Helpers

    private func containsAny(_ text: String, keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }
}
