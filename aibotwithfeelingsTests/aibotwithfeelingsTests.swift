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

  @Test func trialAllowsChatButNotCharacterCreation() {
    let tier = AccessTier.trial(daysRemaining: 3)
    #expect(tier.canChat)
    #expect(!tier.canCreateCharacters)
  }

  @Test func subscribedAllowsEverything() {
    let tier = AccessTier.subscribed
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
