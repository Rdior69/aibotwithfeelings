//
//  UserProfile.swift
//  aibotwithfeelings
//
//  Lightweight profile describing the user and their chosen companion.
//

import Foundation

/// Persisted profile capturing onboarding choices and identity.
public struct UserProfile: Codable, Equatable, Sendable {
    /// The name the user wants to be called.
    public var displayName: String
    /// The name the user gave to their AI companion.
    public var botName: String
    /// The id of the selected personality preset.
    public var personalityID: String
    /// Whether onboarding has been completed.
    public var hasCompletedOnboarding: Bool

    public init(
        displayName: String = "",
        botName: String = "Ava",
        personalityID: String = Personality.default.id,
        hasCompletedOnboarding: Bool = false
    ) {
        self.displayName = displayName
        self.botName = botName
        self.personalityID = personalityID
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    public var personality: Personality {
        Personality.preset(withID: personalityID)
    }

    public static var empty: UserProfile { UserProfile() }
}
