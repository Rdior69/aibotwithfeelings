//
//  AppleIntelligenceService.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import Foundation
import FoundationModels

/// AI service backed by Apple's on-device Foundation Models (requires Apple Intelligence).
@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
actor AppleIntelligenceService: AIServiceProtocol {

    nonisolated var isAvailable: Bool {
        if case .available = SystemLanguageModel.default.availability {
            return true
        }
        return false
    }

    private let emotionEngine = EmotionEngine()

    func generateResponse(
        for userMessage: String,
        personality: BotPersonality,
        recentContext: [MessageContext]
    ) async throws -> AIResponse {
        let availability = SystemLanguageModel.default.availability
        guard case .available = availability else {
            throw AIError.modelUnavailable
        }

        let session = LanguageModelSession(
            instructions: personality.fullSystemPrompt
        )

        // Build context string from recent messages (last 8 turns)
        let contextString = buildContextString(from: recentContext)
        let fullPrompt = contextString.isEmpty
            ? userMessage
            : "\(contextString)\n\nUser: \(userMessage)"

        do {
            let response = try await session.respond(to: fullPrompt)
            let text = response.content

            let detectedEmotion = emotionEngine.detectEmotion(from: userMessage)
                ?? emotionEngine.emotionFromResponse(text, currentEmotion: personality.currentEmotion)

            return AIResponse(text: text, detectedEmotion: detectedEmotion)
        } catch {
            let errDesc = error.localizedDescription.lowercased()
            if errDesc.contains("context") || errDesc.contains("length") {
                throw AIError.contextWindowExceeded
            } else if errDesc.contains("guardrail") || errDesc.contains("safety") {
                throw AIError.guardrailViolation
            }
            throw AIError.generationFailed(error.localizedDescription)
        }
    }

    // MARK: - Helpers

    private func buildContextString(from messages: [MessageContext]) -> String {
        let recent = messages.suffix(8)
        guard !recent.isEmpty else { return "" }
        return recent.map { msg in
            let role = msg.isFromUser ? "User" : "Assistant"
            return "\(role): \(msg.content)"
        }.joined(separator: "\n")
    }
}
