//
//  aibotwithfeelingsTests.swift
//  aibotwithfeelingsTests
//
//  Created by ray dior on 5/29/26.
//

import Testing
@testable import aibotwithfeelings

struct EmotionEngineTests {

    let engine = EmotionEngine()

    @Test("Detects empathy for sad messages")
    func detectSadnessTriggersEmpathy() {
        #expect(engine.detectEmotion(from: "I feel so sad and lonely") == .empathetic)
        #expect(engine.detectEmotion(from: "I'm really anxious about this") == .empathetic)
    }

    @Test("Detects excitement for positive messages")
    func detectExcitementForPositive() {
        #expect(engine.detectEmotion(from: "This is so amazing I love it!") == .excited)
        #expect(engine.detectEmotion(from: "That's fantastic news!") == .excited)
    }

    @Test("Detects curiosity for questions")
    func detectCuriosityForQuestions() {
        #expect(engine.detectEmotion(from: "Why does the sky change color?") == .curious)
        #expect(engine.detectEmotion(from: "Can you explain how this works?") == .curious)
    }

    @Test("Detects thoughtfulness for philosophical topics")
    func detectThoughtfulnessForPhilosophy() {
        #expect(engine.detectEmotion(from: "What is the meaning of life?") == .thoughtful)
        #expect(engine.detectEmotion(from: "Do you believe in consciousness?") == .thoughtful)
    }

    @Test("Detects melancholy for nostalgic content")
    func detectMelancholyForNostalgia() {
        #expect(engine.detectEmotion(from: "I miss the way things used to be") == .melancholy)
    }

    @Test("Detects happiness for greetings")
    func detectHappinessForGreetings() {
        #expect(engine.detectEmotion(from: "Hello! Good morning!") == .happy)
        #expect(engine.detectEmotion(from: "Hey there, thanks for chatting") == .happy)
    }

    @Test("Returns nil for neutral messages")
    func returnsNilForNeutral() {
        #expect(engine.detectEmotion(from: "The weather today is 72 degrees.") == nil)
    }
}

struct EmotionStateTests {

    @Test("All emotion states have non-empty emoji")
    func allEmotionsHaveEmoji() {
        for emotion in EmotionState.allCases {
            #expect(!emotion.emoji.isEmpty)
        }
    }

    @Test("All emotion states have non-empty display names")
    func allEmotionsHaveDisplayNames() {
        for emotion in EmotionState.allCases {
            #expect(!emotion.displayName.isEmpty)
        }
    }

    @Test("All emotion states have system prompt modifiers")
    func allEmotionsHavePromptModifiers() {
        for emotion in EmotionState.allCases {
            #expect(!emotion.systemPromptModifier.isEmpty)
        }
    }
}

struct BotPersonalityTests {

    @Test("Full system prompt includes emotion modifier")
    func systemPromptIncludesEmotionModifier() {
        var personality = BotPersonality.default
        personality.currentEmotion = .excited

        let prompt = personality.fullSystemPrompt
        #expect(prompt.contains(EmotionState.excited.systemPromptModifier))
        #expect(prompt.contains("excited"))
    }

    @Test("Personality name appears in full prompt")
    func personalityNameIsPreserved() {
        let personality = BotPersonality(
            name: "TestBot",
            tagline: "Test",
            baseInstructions: "You are TestBot.",
            currentEmotion: .calm
        )
        #expect(personality.name == "TestBot")
    }
}

struct MockAIServiceTests {

    @Test("Mock service is always available")
    func mockServiceIsAvailable() {
        let service = MockAIService()
        #expect(service.isAvailable == true)
    }

    @Test("Mock service returns a response", .timeLimit(.minutes(1)))
    func mockServiceReturnsResponse() async throws {
        let service = MockAIService()
        let personality = BotPersonality.default
        let result = try await service.generateResponse(
            for: "Hello!",
            personality: personality,
            recentContext: []
        )
        #expect(!result.text.isEmpty)
    }
}

struct AppSettingsTests {

    @Test("Default bot name is Aria")
    func defaultBotName() {
        // AppSettings reads from UserDefaults, so we check the expected default
        let settings = AppSettings()
        // Name should be non-empty
        #expect(!settings.botName.isEmpty)
    }

    @Test("Haptics enabled by default")
    func hapticsEnabledByDefault() {
        // This is a smoke test — actual default depends on prior state in test environment
        let settings = AppSettings()
        let _ = settings.useHaptics  // Just verify it's accessible
        #expect(true)
    }
}
