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

    var errorDescription: String? {
        switch self {
        case .emptyInput:
            return "I didn't catch a message to respond to."
        }
    }
}

protocol AICompanionServing: Sendable {
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

        let normalized = trimmedMessage.lowercased()
        let signal: EmotionSignal
        if normalized.contains("sad") || normalized.contains("anxious") || normalized.contains("stressed") {
            signal = .negative
        } else if normalized.contains("happy") || normalized.contains("great") || normalized.contains("excited") {
            signal = .positive
        } else {
            signal = .uncertain
        }

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
