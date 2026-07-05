//
//  AIProviderConfiguration.swift
//  aibotwithfeelings
//

import Foundation

struct AIProviderConfiguration: Equatable, Sendable {
    let apiKey: String
    let baseURL: URL
    let model: String

    static let defaultBaseURL = URL(string: "https://api.openai.com/v1")!
    static let defaultModel = "gpt-4o-mini"

    init(
        apiKey: String,
        baseURL: URL = AIProviderConfiguration.defaultBaseURL,
        model: String = AIProviderConfiguration.defaultModel
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.model = model
    }

    /// Resolves provider settings from environment variables or Info.plist entries.
    static func current(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        bundle: Bundle = .main
    ) -> AIProviderConfiguration? {
        let apiKey = environment["COMPANION_AI_API_KEY"]
            ?? bundle.object(forInfoDictionaryKey: "COMPANION_AI_API_KEY") as? String

        guard let apiKey, !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        let baseURLString = environment["COMPANION_AI_BASE_URL"]
            ?? bundle.object(forInfoDictionaryKey: "COMPANION_AI_BASE_URL") as? String
            ?? defaultBaseURL.absoluteString

        let model = environment["COMPANION_AI_MODEL"]
            ?? bundle.object(forInfoDictionaryKey: "COMPANION_AI_MODEL") as? String
            ?? defaultModel

        guard let baseURL = URL(string: baseURLString) else {
            return AIProviderConfiguration(apiKey: apiKey, model: model)
        }

        return AIProviderConfiguration(apiKey: apiKey, baseURL: baseURL, model: model)
    }
}
