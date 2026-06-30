//
//  FallbackAICompanionService.swift
//  aibotwithfeelings
//

import Foundation

/// Tries a primary AI provider and falls back to a local mock when unavailable.
struct FallbackAICompanionService: AICompanionServing {
    let primary: AICompanionServing?
    let fallback: AICompanionServing

    init(primary: AICompanionServing?, fallback: AICompanionServing = MockAICompanionService()) {
        self.primary = primary
        self.fallback = fallback
    }

    func generateReply(
        to userMessage: String,
        profile: UserProfile?,
        memories: [MemoryItem],
        currentEmotion: EmotionState
    ) async throws -> AIReply {
        guard let primary else {
            return try await fallback.generateReply(
                to: userMessage,
                profile: profile,
                memories: memories,
                currentEmotion: currentEmotion
            )
        }

        do {
            return try await primary.generateReply(
                to: userMessage,
                profile: profile,
                memories: memories,
                currentEmotion: currentEmotion
            )
        } catch {
            return try await fallback.generateReply(
                to: userMessage,
                profile: profile,
                memories: memories,
                currentEmotion: currentEmotion
            )
        }
    }
}
