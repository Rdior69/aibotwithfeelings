//
//  HTTPAICompanionService.swift
//  aibotwithfeelings
//

import Foundation

struct HTTPAICompanionService: AICompanionServing {
    private let configuration: AIProviderConfiguration
    private let session: URLSession

    init(configuration: AIProviderConfiguration, session: URLSession = .shared) {
        self.configuration = configuration
        self.session = session
    }

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

        let requestBody = ChatCompletionRequest(
            model: configuration.model,
            messages: [
                .init(role: "system", content: CompanionPromptBuilder.systemPrompt(
                    profile: profile,
                    memories: memories,
                    currentEmotion: currentEmotion
                )),
                .init(role: "user", content: CompanionPromptBuilder.userPrompt(for: trimmedMessage))
            ],
            temperature: 0.7
        )

        var request = URLRequest(url: configuration.baseURL.appending(path: "chat/completions"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.networkFailure
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw AIServiceError.providerFailure(statusCode: httpResponse.statusCode)
        }

        let completion = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let text = completion.choices.first?.message.content?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !text.isEmpty else {
            throw AIServiceError.emptyResponse
        }

        let signal = EmotionSignalDetector.detect(in: trimmedMessage)
        let nextEmotion = EmotionEngine.nextState(from: currentEmotion, signal: signal)
        let memoryCandidate = trimmedMessage.count > 24 ? trimmedMessage : nil

        return AIReply(text: text, emotion: nextEmotion, memoryCandidate: memoryCandidate)
    }
}

private struct ChatCompletionRequest: Encodable {
    struct Message: Encodable {
        let role: String
        let content: String
    }

    let model: String
    let messages: [Message]
    let temperature: Double
}

private struct ChatCompletionResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String?
        }

        let message: Message
    }

    let choices: [Choice]
}

enum EmotionSignalDetector {
    static func detect(in message: String) -> EmotionSignal {
        let normalized = message.lowercased()
        if normalized.contains("sad") || normalized.contains("anxious") || normalized.contains("stressed") {
            return .negative
        }
        if normalized.contains("happy") || normalized.contains("great") || normalized.contains("excited") {
            return .positive
        }
        return .uncertain
    }
}
