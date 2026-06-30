//
//  EmotionEngineTests.swift
//  aibotwithfeelingsTests
//

import Testing
import Foundation
@testable import aibotwithfeelings

struct EmotionEngineTests {
    let engine = EmotionEngine()

    @Test func positiveTextHasPositiveSentiment() {
        let signal = engine.analyze("I am so happy and grateful today!")
        #expect(signal.sentiment > 0)
        #expect((signal.contributions[.joy] ?? 0) > 0)
    }

    @Test func negativeTextHasNegativeSentiment() {
        let signal = engine.analyze("I feel so sad and lonely")
        #expect(signal.sentiment < 0)
        #expect((signal.contributions[.sadness] ?? 0) > 0)
    }

    @Test func anxietyIsDetected() {
        let signal = engine.analyze("I'm really anxious and overwhelmed about work")
        #expect((signal.contributions[.anxiety] ?? 0) > 0)
        #expect(signal.sentiment < 0)
    }

    @Test func negationFlipsPositive() {
        let signal = engine.analyze("I am not happy")
        // "not happy" should not register as joy.
        #expect((signal.contributions[.joy] ?? 0) == 0)
        #expect(signal.sentiment <= 0)
    }

    @Test func emptyTextIsNeutral() {
        let signal = engine.analyze("   ")
        #expect(signal == EmotionSignal.empty)
    }

    @Test func moodEvolvesTowardSignal() {
        let signal = engine.analyze("I love this, I'm so happy!")
        let mood = engine.updatedMood(from: .neutral, applying: signal, sensitivity: 0.9)
        #expect(mood.valence > MoodState.neutral.valence)
        #expect(mood.dominant.isPositive)
    }

    @Test func higherSensitivityReactsMoreStrongly() {
        let signal = engine.analyze("I am sad")
        let lowReact = engine.updatedMood(from: .neutral, applying: signal, sensitivity: 0.1)
        let highReact = engine.updatedMood(from: .neutral, applying: signal, sensitivity: 1.0)
        #expect(highReact.score(for: .sadness) > lowReact.score(for: .sadness))
    }

    @Test func moodDecaysTowardBaseline() {
        let excited = MoodState(scores: [.excitement: 0.9])
        let decayed = excited.decayed(by: 0.5)
        #expect(decayed.score(for: .excitement) < 0.9)
        #expect(decayed.score(for: .excitement) > 0)
    }

    @Test func scoresAreClamped() {
        let mood = MoodState(scores: [.joy: 5.0, .anger: -3.0])
        #expect(mood.score(for: .joy) == 1.0)
        #expect(mood.score(for: .anger) == 0.0)
    }
}
