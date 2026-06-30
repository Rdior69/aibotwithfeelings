//
//  ChatViewModel.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
@MainActor
final class ChatViewModel {

    // MARK: - State

    var messages: [Message] = []
    var inputText: String = ""
    var isTyping: Bool = false
    var currentEmotion: EmotionState = .calm
    var errorMessage: String? = nil
    var conversationID: UUID = UUID()

    // MARK: - Dependencies

    private let aiService: any AIServiceProtocol
    private var personality: BotPersonality
    private let settings: AppSettings
    private let emotionEngine = EmotionEngine()
    private var modelContext: ModelContext?

    // MARK: - Init

    init(settings: AppSettings) {
        self.settings = settings
        self.personality = BotPersonality(
            name: settings.botName,
            tagline: BotPersonality.default.tagline,
            baseInstructions: BotPersonality.default.baseInstructions,
            currentEmotion: .calm
        )

        // Choose AI service based on availability
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *),
           settings.useAppleIntelligence {
            let appleService = AppleIntelligenceService()
            // Run availability check synchronously via actor
            self.aiService = appleService as any AIServiceProtocol
        } else {
            self.aiService = MockAIService()
        }
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadRecentMessages()
    }

    // MARK: - AI Availability

    var isUsingAppleIntelligence: Bool {
        !(aiService is MockAIService)
    }

    // MARK: - Sending Messages

    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if settings.useHaptics {
            HapticManager.impact(.medium)
        }

        let userMsg = Message(content: trimmed, isFromUser: true, conversationID: conversationID)
        messages.append(userMsg)
        modelContext?.insert(userMsg)

        inputText = ""
        errorMessage = nil
        isTyping = true

        // Update emotion based on user input
        if let detectedEmotion = emotionEngine.detectEmotion(from: trimmed) {
            withAnimation(.easeInOut(duration: 0.5)) {
                currentEmotion = detectedEmotion
            }
        }
        personality.currentEmotion = currentEmotion

        Task {
            await generateBotResponse(for: trimmed)
        }
    }

    private func generateBotResponse(for userMessage: String) async {
        defer { isTyping = false }

        let contextSnapshot = messages.map { MessageContext(content: $0.content, isFromUser: $0.isFromUser) }

        do {
            let result = try await aiService.generateResponse(
                for: userMessage,
                personality: personality,
                recentContext: contextSnapshot
            )

            let botMsg = Message(
                content: result.text,
                isFromUser: false,
                emotion: result.detectedEmotion,
                conversationID: conversationID
            )
            messages.append(botMsg)
            modelContext?.insert(botMsg)

            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                currentEmotion = result.detectedEmotion
            }
            personality.currentEmotion = currentEmotion

            if settings.useHaptics {
                HapticManager.impact(.light)
            }

        } catch AIError.modelUnavailable {
            // Fall back to mock gracefully
            let fallback = MockAIService()
            do {
                let result = try await fallback.generateResponse(
                    for: userMessage,
                    personality: personality,
                    recentContext: contextSnapshot
                )
                let botMsg = Message(
                    content: result.text,
                    isFromUser: false,
                    emotion: result.detectedEmotion,
                    conversationID: conversationID
                )
                messages.append(botMsg)
                modelContext?.insert(botMsg)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    currentEmotion = result.detectedEmotion
                }
                personality.currentEmotion = currentEmotion
            } catch {
                errorMessage = error.localizedDescription
            }

        } catch AIError.contextWindowExceeded {
            startNewConversation()
            errorMessage = "Starting a fresh conversation — it was getting long!"

        } catch {
            errorMessage = error.localizedDescription
            if settings.useHaptics {
                HapticManager.notification(.error)
            }
        }
    }

    // MARK: - Conversation Management

    func startNewConversation() {
        conversationID = UUID()
        messages.removeAll()
        currentEmotion = .calm
        personality.currentEmotion = .calm
        errorMessage = nil
    }

    func updateBotName(_ name: String) {
        personality = BotPersonality(
            name: name,
            tagline: personality.tagline,
            baseInstructions: personality.baseInstructions,
            currentEmotion: personality.currentEmotion
        )
    }

    // MARK: - Persistence

    private func loadRecentMessages() {
        guard let context = modelContext else { return }
        let fetchDescriptor = FetchDescriptor<Message>(
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        if let fetched = try? context.fetch(fetchDescriptor) {
            // Load last conversation
            if let lastID = fetched.last?.conversationID {
                conversationID = lastID
                messages = fetched.filter { $0.conversationID == lastID }
                if let lastEmotion = messages.last(where: { !$0.isFromUser })?.emotion {
                    currentEmotion = lastEmotion
                    personality.currentEmotion = lastEmotion
                }
            }
        }
    }
}
