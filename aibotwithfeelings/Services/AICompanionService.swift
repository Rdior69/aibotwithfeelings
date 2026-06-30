//
//  AICompanionService.swift
//  aibotwithfeelings
//

import Foundation

struct AIReply {
    let text: String
    let emotion: EmotionState
    let memoryCandidate: String?
}

enum AIServiceError: LocalizedError {
    case emptyInput
    case networkFailure
    case providerFailure(statusCode: Int)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .emptyInput:
            return "I didn't catch a message to respond to."
        case .networkFailure:
            return "The AI service could not be reached."
        case .providerFailure(let statusCode):
            return "The AI service returned an error (HTTP \(statusCode))."
        case .emptyResponse:
            return "The AI service returned an empty response."
        }
    }
}

protocol AICompanionServing {
    func generateReply(
        to userMessage: String,
        profile: UserProfile?,
        memories: [MemoryItem],
        currentEmotion: EmotionState
    ) async throws -> AIReply
}

struct MockAICompanionService: AICompanionServing {
    func generateReply(
        to userMessage: String,
        profile: UserProfile?,
        memories: [MemoryItem],
        currentEmotion: EmotionState
    ) async throws -> AIReply {
        let trimmedMessage = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else {
            throw AIServiceError.emptyInput
        }

        try await Task.sleep(for: .milliseconds(350))

        let signal = EmotionSignalDetector.detect(in: trimmedMessage)
        let nextEmotion = EmotionEngine.nextState(from: currentEmotion, signal: signal)
        let memoryLine = memories.first?.detail ?? "I am still learning what matters most to you."
        let tone = profile?.preferredTone ?? .supportive
        let name = profile?.preferredName.isEmpty == false ? profile?.preferredName ?? "friend" : "friend"

        let prefix: String
        switch tone {
        case .supportive:
            prefix = "Thanks for sharing, \(name)."
        case .playful:
            prefix = "I hear you, \(name) - and I am right here with you."
        case .direct:
            prefix = "Noted, \(name). Let us focus on what helps next."
        }

        let response = "\(prefix) \(memoryLine)"
        let memoryCandidate = trimmedMessage.count > 24 ? trimmedMessage : nil

        return AIReply(text: response, emotion: nextEmotion, memoryCandidate: memoryCandidate)
    }
}
