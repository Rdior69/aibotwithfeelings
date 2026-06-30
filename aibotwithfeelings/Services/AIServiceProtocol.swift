//
//  AIServiceProtocol.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import Foundation

struct AIResponse: Sendable {
    let text: String
    let detectedEmotion: EmotionState
}

/// Lightweight, Sendable snapshot of a message for passing across actor boundaries.
struct MessageContext: Sendable {
    let content: String
    let isFromUser: Bool
}

enum AIError: LocalizedError {
    case modelUnavailable
    case notInitialized
    case generationFailed(String)
    case contextWindowExceeded
    case guardrailViolation

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "Apple Intelligence is not available on this device. Enable it in Settings > Apple Intelligence."
        case .notInitialized:
            return "AI service not initialized."
        case .generationFailed(let reason):
            return "Response generation failed: \(reason)"
        case .contextWindowExceeded:
            return "Conversation is too long. Starting a new session."
        case .guardrailViolation:
            return "That message couldn't be processed safely."
        }
    }
}

protocol AIServiceProtocol: Sendable {
    func generateResponse(
        for userMessage: String,
        personality: BotPersonality,
        recentContext: [MessageContext]
    ) async throws -> AIResponse

    var isAvailable: Bool { get }
}
