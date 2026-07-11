//
//  AICompanionProvider.swift
//  aibotwithfeelings
//

import Foundation

/// A registered AI backend that implements companion replies and advertises
/// optional capabilities for feature adaptation.
protocol AICompanionProvider: AICompanionServing, Sendable {
    var kind: AIProviderKind { get }
    var capabilities: AIProviderCapabilities { get }
}
