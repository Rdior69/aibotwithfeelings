//
//  aibotwithfeelingsTests.swift
//  aibotwithfeelingsTests
//

import Testing
@testable import aibotwithfeelings

struct IntentAnalyzerTests {

  private let analyzer = IntentAnalyzer()

  @Test func selectsWebSearchForFactualQuestions() {
    let selection = analyzer.analyze("What is quantum entanglement?")
    #expect(selection.tools.contains(.webSearch))
  }

  @Test func selectsWeatherForWeatherQueries() {
    let selection = analyzer.analyze("What's the weather like in Seattle today?")
    #expect(selection.tools.contains(.weather))
  }

  @Test func selectsWikipediaForHistoricalTopics() {
    let selection = analyzer.analyze("Tell me about the history of jazz music")
    #expect(selection.tools.contains(.wikipedia))
  }

  @Test func selectsNewsForCurrentEvents() {
    let selection = analyzer.analyze("What's in the news right now?")
    #expect(selection.tools.contains(.news))
  }

  @Test func alwaysReachesOutwardOnSubstantiveMessages() {
    let selection = analyzer.analyze("I'm feeling stuck in my career")
    #expect(!selection.tools.isEmpty)
    #expect(selection.tools.contains(.creativeSpark))
  }

  @Test func selectsQuoteWisdomForMotivation() {
    let selection = analyzer.analyze("I need some motivation and wisdom today")
    #expect(selection.tools.contains(.quoteWisdom))
  }
}

struct AvaPersonalityTests {

  @Test func systemPromptForbidsMirroring() {
    let prompt = AvaPersonality.systemPrompt
    #expect(prompt.contains("NOT a mirror"))
    #expect(prompt.contains("NEVER open with"))
    #expect(prompt.contains("It sounds like"))
  }

  @Test func systemPromptRequiresExternalIntelUsage() {
    let prompt = AvaPersonality.systemPrompt
    #expect(prompt.contains("external intel"))
    #expect(prompt.contains("concrete fact"))
  }

  @Test func systemPromptEmphasizesHumanFeelings() {
    let prompt = AvaPersonality.systemPrompt
    #expect(prompt.contains("Feel Like a Human"))
    #expect(prompt.contains("emotions"))
  }
}

struct CharacterPromptBuilderTests {

  @Test func builtInCharacterUsesAvaPersonality() {
    let prompt = CharacterPromptBuilder.systemPrompt(for: .ava)
    #expect(prompt == AvaPersonality.systemPrompt)
  }

  @Test func customCharacterIncludesNameAndAppearance() {
    var character = AICharacter.blank()
    character.name = "Luna"
    character.appearanceDescription = "Silver hair, violet eyes, moonlit presence"
    let prompt = CharacterPromptBuilder.systemPrompt(for: character)
    #expect(prompt.contains("Luna"))
    #expect(prompt.contains("Silver hair"))
    #expect(prompt.contains("Emotional Expression"))
  }
}

struct AccessTierTests {

  @Test func noneBlocksAccess() {
    let tier = AccessTier.none
    #expect(!tier.canChat)
    #expect(!tier.canCreateCharacters)
  }

  @Test func trialAllowsChatButNotCharacterCreation() {
    let tier = AccessTier.trial(daysRemaining: 3)
    #expect(tier.canChat)
    #expect(!tier.canCreateCharacters)
  }

  @Test func premiumAllowsEverything() {
    let tier = AccessTier.premium
    #expect(tier.canChat)
    #expect(tier.canCreateCharacters)
  }

  @Test func expiredBlocksChat() {
    let tier = AccessTier.expired
    #expect(!tier.canChat)
    #expect(!tier.canCreateCharacters)
  }
}

struct AICharacterTests {

  @Test func maxCharactersIsTwenty() {
    #expect(AICharacter.maxPremiumCharacters == 20)
  }

  @Test func blankCharacterIsInvalidUntilFilled() {
    let character = AICharacter.blank()
    #expect(!character.isValid)
  }
}

struct AvaAntiEchoFilterTests {

  private let filter = AvaAntiEchoFilter()

  @Test func removesDirectUserMessageEcho() {
    let reply = "I feel stuck in my career and I don't know what to do. The sharper truth is that stuck usually means one value is being overfed and another is starving."
    let cleaned = filter.cleanedReply(reply, userMessage: "I feel stuck in my career and I don't know what to do")
    #expect(cleaned.hasPrefix("The sharper truth"))
  }

  @Test func removesBannedEchoOpeners() {
    let reply = "It sounds like you're exhausted. Tiny brutal move: protect one hour tonight like it belongs to someone you love."
    let cleaned = filter.cleanedReply(reply, userMessage: "I'm exhausted")
    #expect(cleaned.hasPrefix("Tiny brutal move"))
  }

  @Test func preservesSubstantiveReplies() {
    let reply = "Tiny brutal move: protect one hour tonight like it belongs to someone you love."
    let cleaned = filter.cleanedReply(reply, userMessage: "I'm exhausted")
    #expect(cleaned == reply)
  }
}

struct AvaSafetyBoundaryTests {

  private let boundary = AvaSafetyBoundary()

  @Test func flagsHighRiskSelfHarmMessages() {
    let assessment = boundary.assess("I want to kill myself tonight")

    if case .crisis(let message) = assessment {
      #expect(message.contains("988"))
      #expect(message.contains("emergency services"))
    } else {
      Issue.record("Expected a crisis assessment")
    }
  }

  @Test func allowsLowRiskSadnessMessages() {
    #expect(boundary.assess("I feel sad and lonely today") == .allow)
  }
}

struct AvaBrainSafetyTests {

  @MainActor
  @Test func crisisMessagesBypassGeminiAndExternalTools() async throws {
    let brain = AvaBrain()
    let response = try await brain.respond(
      to: "I want to end my life",
      history: [],
      character: .ava
    )

    #expect(response.toolsUsed == ["Safety Boundary"])
    #expect(response.content.contains("988"))
    #expect(brain.phase == .idle)
  }
}
