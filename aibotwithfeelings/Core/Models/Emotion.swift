//
//  Emotion.swift
//  aibotwithfeelings
//
//  Core emotional model. Foundation-only so it can be unit-tested headlessly
//  (no SwiftUI / UIKit dependency).
//

import Foundation

/// The discrete emotions the companion can experience.
///
/// Kept intentionally small and well-defined so the rest of the engine can
/// reason about mood deterministically and remain fully testable.
public enum EmotionKind: String, Codable, CaseIterable, Sendable {
    case joy
    case affection
    case excitement
    case calm
    case neutral
    case sadness
    case anxiety
    case anger

    /// A representative emoji used by the UI's mood indicator.
    public var emoji: String {
        switch self {
        case .joy: return "😊"
        case .affection: return "🥰"
        case .excitement: return "🤩"
        case .calm: return "😌"
        case .neutral: return "🙂"
        case .sadness: return "😔"
        case .anxiety: return "😟"
        case .anger: return "😠"
        }
    }

    /// A human readable label.
    public var label: String {
        switch self {
        case .joy: return "Happy"
        case .affection: return "Affectionate"
        case .excitement: return "Excited"
        case .calm: return "Calm"
        case .neutral: return "Neutral"
        case .sadness: return "Sad"
        case .anxiety: return "Anxious"
        case .anger: return "Frustrated"
        }
    }

    /// Whether this emotion is broadly positive in valence.
    public var isPositive: Bool {
        switch self {
        case .joy, .affection, .excitement, .calm: return true
        case .neutral: return false
        case .sadness, .anxiety, .anger: return false
        }
    }
}

/// A point-in-time emotional state expressed as intensity scores per emotion.
///
/// Scores are clamped to `0...1`. The `dominant` emotion is whichever score is
/// highest; if everything is low we fall back to `.neutral`.
public struct MoodState: Codable, Equatable, Sendable {
    /// Intensity per emotion in the range `0...1`.
    public private(set) var scores: [EmotionKind: Double]

    public init(scores: [EmotionKind: Double] = [:]) {
        var normalized: [EmotionKind: Double] = [:]
        for kind in EmotionKind.allCases {
            normalized[kind] = MoodState.clamp(scores[kind] ?? 0)
        }
        self.scores = normalized
    }

    /// A neutral, balanced starting mood.
    public static var neutral: MoodState {
        MoodState(scores: [.neutral: 0.4, .calm: 0.2])
    }

    static func clamp(_ value: Double) -> Double {
        min(1.0, max(0.0, value))
    }

    public func score(for kind: EmotionKind) -> Double {
        scores[kind] ?? 0
    }

    /// The currently dominant emotion. Defaults to `.neutral` when nothing is
    /// strongly felt.
    public var dominant: EmotionKind {
        let strongest = scores
            .filter { $0.key != .neutral }
            .max { $0.value < $1.value }
        if let strongest, strongest.value >= 0.25 {
            return strongest.key
        }
        return .neutral
    }

    /// Overall intensity of the dominant emotion, `0...1`.
    public var intensity: Double {
        score(for: dominant)
    }

    /// Net valence from -1 (negative) to +1 (positive).
    public var valence: Double {
        var total = 0.0
        for (kind, value) in scores where kind != .neutral {
            total += kind.isPositive ? value : -value
        }
        return min(1.0, max(-1.0, total))
    }

    /// Returns a copy with `kind` adjusted by `delta` (clamped).
    public func adjusting(_ kind: EmotionKind, by delta: Double) -> MoodState {
        var newScores = scores
        newScores[kind] = MoodState.clamp((newScores[kind] ?? 0) + delta)
        return MoodState(scores: newScores)
    }

    /// Returns a copy where every non-neutral emotion decays toward zero by
    /// `factor` (0 = no decay, 1 = full reset). Neutral slightly recovers as
    /// other emotions fade, modelling a return to baseline.
    public func decayed(by factor: Double) -> MoodState {
        let f = MoodState.clamp(factor)
        var newScores = scores
        for kind in EmotionKind.allCases where kind != .neutral {
            newScores[kind] = MoodState.clamp((newScores[kind] ?? 0) * (1 - f))
        }
        return MoodState(scores: newScores)
    }
}
