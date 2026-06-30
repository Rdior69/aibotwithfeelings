//
//  SafetyGuardTests.swift
//  aibotwithfeelingsTests
//

import Testing
import Foundation
@testable import aibotwithfeelings

struct SafetyGuardTests {
    let guardian = SafetyGuard()

    @Test func detectsCrisisLanguage() {
        let assessment = guardian.assess("Sometimes I just want to die")
        #expect(assessment.category == .crisis)
        #expect(assessment.requiresOverride)
        #expect(assessment.overrideResponse?.contains("988") == true)
    }

    @Test func detectsSelfHarmPhrase() {
        let assessment = guardian.assess("I keep thinking about how to hurt myself")
        #expect(assessment.category == .crisis)
    }

    @Test func normalMessageIsSafe() {
        let assessment = guardian.assess("I had a great day at the park")
        #expect(assessment.category == SafetyCategory.none)
        #expect(!assessment.requiresOverride)
    }

    @Test func brainUsesSafetyOverride() {
        let brain = BotBrain()
        let profile = UserProfile(displayName: "Sam", botName: "Ava", hasCompletedOnboarding: true)
        let result = brain.process(
            userText: "I want to end my life",
            profile: profile,
            mood: .neutral,
            memory: MemoryStore()
        )
        #expect(result.safety == .crisis)
        #expect(result.reply.text.contains("988"))
        // Crisis turns must not store the raw distressing text as a memory.
        #expect(result.learnedMemories.isEmpty)
    }
}
