//
//  aibotwithfeelingsTests.swift
//  aibotwithfeelingsTests
//
//  Smoke test confirming the core engine assembles and runs a full turn.
//

import Testing
import Foundation
@testable import aibotwithfeelings

struct aibotwithfeelingsTests {

    @Test func fullTurnProducesReply() async throws {
        let brain = BotBrain()
        let profile = UserProfile(displayName: "Sam", botName: "Ava",
                                  personalityID: "companion",
                                  hasCompletedOnboarding: true)
        let result = brain.process(
            userText: "Hi there!",
            profile: profile,
            mood: .neutral,
            memory: MemoryStore()
        )
        #expect(result.reply.sender == .bot)
        #expect(!result.reply.text.isEmpty)
        #expect(result.safety == SafetyCategory.none)
    }
}
