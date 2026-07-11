//
//  AIProviderRegistry.swift
//  aibotwithfeelings
//

import Foundation

enum AIProviderRegistryError: Error, Equatable, Sendable {
    case unregisteredKind(AIProviderKind)
    case kindMismatch(expected: AIProviderKind, received: AIProviderKind)
}

/// Builds a concrete provider for a resolved configuration.
protocol AICompanionProviderBuilding: Sendable {
    var kind: AIProviderKind { get }
    var capabilities: AIProviderCapabilities { get }
    func makeProvider(configuration: AIProviderConfiguration) -> any AICompanionProvider
}

/// Abstraction for dynamic provider registration and resolution.
protocol AIProviderRegistering: Sendable {
    func register(_ builder: any AICompanionProviderBuilding) async
    func registeredKinds() async -> [AIProviderKind]
    func capabilities(for kind: AIProviderKind) async -> AIProviderCapabilities?
    func provider(for configuration: AIProviderConfiguration) async throws -> any AICompanionProvider
}

actor AIProviderRegistry: AIProviderRegistering {
    private var builders: [AIProviderKind: any AICompanionProviderBuilding] = [:]

    func register(_ builder: any AICompanionProviderBuilding) {
        builders[builder.kind] = builder
    }

    func registeredKinds() -> [AIProviderKind] {
        builders.keys.sorted { $0.rawValue < $1.rawValue }
    }

    func capabilities(for kind: AIProviderKind) -> AIProviderCapabilities? {
        builders[kind]?.capabilities
    }

    func provider(for configuration: AIProviderConfiguration) throws -> any AICompanionProvider {
        guard let builder = builders[configuration.kind] else {
            throw AIProviderRegistryError.unregisteredKind(configuration.kind)
        }

        guard builder.kind == configuration.kind else {
            throw AIProviderRegistryError.kindMismatch(
                expected: builder.kind,
                received: configuration.kind
            )
        }

        return builder.makeProvider(configuration: configuration)
    }
}
