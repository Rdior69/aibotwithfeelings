//
//  AIProviderConfiguration.swift
//  aibotwithfeelings
//

import Foundation

enum AIProviderKind: String, Sendable, Codable, CaseIterable {
    case openAICompatible
}

struct AIProviderConfiguration: Equatable, Sendable {
    let kind: AIProviderKind
    let apiKey: String
    let baseURL: URL
    let model: String

    static let defaultBaseURL = URL(string: "https://api.openai.com/v1")!
    static let defaultModel = "gpt-4o-mini"
    static let defaultKind: AIProviderKind = .openAICompatible

    init(
        kind: AIProviderKind = AIProviderConfiguration.defaultKind,
        apiKey: String,
        baseURL: URL = AIProviderConfiguration.defaultBaseURL,
        model: String = AIProviderConfiguration.defaultModel
    ) {
        self.kind = kind
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.model = model
    }
}

protocol AIProviderConfigurationResolving: Sendable {
    func resolve() -> AIProviderConfiguration?
}

struct EnvironmentAIProviderConfigurationResolver: AIProviderConfigurationResolving {
    private let environment: [String: String]
    private let bundle: Bundle

    init(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        bundle: Bundle = .main
    ) {
        self.environment = environment
        self.bundle = bundle
    }

    func resolve() -> AIProviderConfiguration? {
        let apiKey = environment["COMPANION_AI_API_KEY"]
            ?? bundle.object(forInfoDictionaryKey: "COMPANION_AI_API_KEY") as? String

        guard let apiKey,
              !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        let kindString = environment["COMPANION_AI_PROVIDER_KIND"]
            ?? bundle.object(forInfoDictionaryKey: "COMPANION_AI_PROVIDER_KIND") as? String
            ?? AIProviderKind.openAICompatible.rawValue

        guard let kind = AIProviderKind(rawValue: kindString) else {
            return nil
        }

        let baseURLString = environment["COMPANION_AI_BASE_URL"]
            ?? bundle.object(forInfoDictionaryKey: "COMPANION_AI_BASE_URL") as? String
            ?? AIProviderConfiguration.defaultBaseURL.absoluteString

        let model = environment["COMPANION_AI_MODEL"]
            ?? bundle.object(forInfoDictionaryKey: "COMPANION_AI_MODEL") as? String
            ?? AIProviderConfiguration.defaultModel

        guard let baseURL = URL(string: baseURLString) else {
            return AIProviderConfiguration(kind: kind, apiKey: apiKey, model: model)
        }

        return AIProviderConfiguration(kind: kind, apiKey: apiKey, baseURL: baseURL, model: model)
    }
}
