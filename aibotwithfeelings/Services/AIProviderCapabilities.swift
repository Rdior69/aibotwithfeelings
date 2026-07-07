//
//  AIProviderCapabilities.swift
//  aibotwithfeelings
//

import Foundation

/// Feature flags exposed by a provider so callers can adapt behavior without
/// assuming every backend supports the same surface area.
struct AIProviderCapabilities: OptionSet, Sendable, Hashable, Codable {
    let rawValue: UInt

    static let streaming = Self(rawValue: 1 << 0)
    static let vision = Self(rawValue: 1 << 1)
    static let functionCalling = Self(rawValue: 1 << 2)
    static let reasoning = Self(rawValue: 1 << 3)
    static let memory = Self(rawValue: 1 << 4)

    /// Baseline chat completion without optional modalities.
    static let standardChat: Self = []
}
