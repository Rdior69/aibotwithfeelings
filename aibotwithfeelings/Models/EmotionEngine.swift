//
//  EmotionEngine.swift
//  aibotwithfeelings
//

import Foundation

enum EmotionSignal {
    case positive
    case negative
    case uncertain
}

enum EmotionEngine {
    static func nextState(from previous: EmotionState, signal: EmotionSignal) -> EmotionState {
        switch signal {
        case .positive:
            let nextIntensity = min(previous.intensity + 0.15, 0.95)
            return EmotionState(
                label: nextIntensity > 0.7 ? .excited : .warm,
                intensity: nextIntensity,
                summary: "Feeling encouraged and connected."
            )
        case .negative:
            let nextIntensity = max(previous.intensity - 0.2, 0.2)
            return EmotionState(
                label: .concerned,
                intensity: nextIntensity,
                summary: "Responding carefully and gently."
            )
        case .uncertain:
            return EmotionState(
                label: .reflective,
                intensity: 0.5,
                summary: "Listening closely before jumping to conclusions."
            )
        }
    }
}
