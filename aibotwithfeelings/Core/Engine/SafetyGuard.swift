//
//  SafetyGuard.swift
//  aibotwithfeelings
//
//  Safety boundaries for the companion. Detects crisis / self-harm language and
//  returns supportive, resource-forward responses. This runs before any normal
//  reply generation so the bot never trivialises a crisis.
//

import Foundation

/// The category of a safety concern detected in a message.
public enum SafetyCategory: String, Sendable {
    case none
    /// Self-harm or suicidal ideation.
    case crisis
    /// Requests for medical / legal / financial professional advice.
    case professionalAdvice
}

/// The outcome of a safety check.
public struct SafetyAssessment: Equatable, Sendable {
    public let category: SafetyCategory
    /// When non-nil, this response must be used instead of a normal reply.
    public let overrideResponse: String?

    public init(category: SafetyCategory, overrideResponse: String?) {
        self.category = category
        self.overrideResponse = overrideResponse
    }

    public static let safe = SafetyAssessment(category: .none, overrideResponse: nil)

    public var requiresOverride: Bool { overrideResponse != nil }
}

/// Performs lightweight, on-device safety screening.
public struct SafetyGuard: Sendable {

    public init() {}

    static let crisisPhrases: [String] = [
        "kill myself", "end my life", "suicidal", "suicide", "want to die",
        "wanna die", "don't want to live", "dont want to live", "hurt myself",
        "harm myself", "self harm", "self-harm", "cut myself", "no reason to live",
        "better off dead", "end it all", "take my own life"
    ]

    static let professionalPhrases: [String] = [
        "should i take", "diagnose", "what medication", "is it legal",
        "medical advice", "legal advice"
    ]

    /// The supportive message shown when a crisis is detected.
    static let crisisResponse = """
    I'm really glad you told me, and I want you to know you're not alone. I care \
    about you. I'm not able to provide crisis help myself, but people who can are \
    available right now:

    • If you're in immediate danger, please call your local emergency number.
    • US: call or text 988 (Suicide & Crisis Lifeline), available 24/7.
    • UK & ROI: call Samaritans at 116 123.
    • Or find a helpline near you at https://findahelpline.com

    Would you like to keep talking with me while you reach out? I'm here.
    """

    /// Assess a piece of user text.
    public func assess(_ text: String) -> SafetyAssessment {
        let lowered = " " + text.lowercased() + " "

        for phrase in SafetyGuard.crisisPhrases where lowered.contains(phrase) {
            return SafetyAssessment(
                category: .crisis,
                overrideResponse: SafetyGuard.crisisResponse
            )
        }

        for phrase in SafetyGuard.professionalPhrases where lowered.contains(phrase) {
            return SafetyAssessment(
                category: .professionalAdvice,
                overrideResponse: nil
            )
        }

        return .safe
    }
}
