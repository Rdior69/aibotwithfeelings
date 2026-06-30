//
//  ChatView.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var settings

    @State private var viewModel: ChatViewModel

    @State private var scrollProxy: ScrollViewProxy?
    @State private var showSettings = false
    @State private var showNewChatAlert = false
    @FocusState private var inputFocused: Bool

    init(settings: AppSettings) {
        _viewModel = State(initialValue: ChatViewModel(settings: settings))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    emotionHeaderBanner
                    messageList
                    inputBar
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environment(settings)
            }
            .alert("Start New Chat?", isPresented: $showNewChatAlert) {
                Button("Start Fresh", role: .destructive) {
                    viewModel.startNewConversation()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear the current conversation. Your history is saved.")
            }
        }
        .onAppear {
            viewModel.configure(modelContext: modelContext)
        }
        .onChange(of: settings.botName) { _, name in
            viewModel.updateBotName(name)
        }
    }

    // MARK: - Emotion Header

    private var emotionHeaderBanner: some View {
        HStack(spacing: 12) {
            BotAvatarView(
                emotion: viewModel.currentEmotion,
                size: 44,
                isTyping: viewModel.isTyping
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(settings.botName)
                    .font(.headline)
                    .fontWeight(.semibold)

                if viewModel.isTyping {
                    Text("typing…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .transition(.opacity)
                } else if settings.showEmotionIndicator {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(viewModel.currentEmotion.primaryColor)
                            .frame(width: 8, height: 8)
                        Text("Feeling \(viewModel.currentEmotion.displayName.lowercased())")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.isTyping)

            Spacer()

            // AI mode indicator
            if viewModel.isUsingAppleIntelligence {
                Label("On-device", systemImage: "apple.intelligence")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [
                    viewModel.currentEmotion.primaryColor.opacity(0.15),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .animation(.easeInOut(duration: 0.6), value: viewModel.currentEmotion)
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.messages.isEmpty {
                        emptyStateView
                            .padding(.top, 60)
                    } else {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(
                                message: message,
                                botEmotion: viewModel.currentEmotion,
                                botName: settings.botName
                            )
                            .id(message.id)
                        }
                    }

                    if viewModel.isTyping {
                        TypingIndicatorView(emotion: viewModel.currentEmotion)
                            .id("typing")
                            .transition(.asymmetric(
                                insertion: .push(from: .bottom),
                                removal: .opacity
                            ))
                    }

                    if let error = viewModel.errorMessage {
                        ErrorBannerView(message: error) {
                            viewModel.errorMessage = nil
                        }
                        .padding(.horizontal, 16)
                        .transition(.opacity)
                    }

                    Color.clear.frame(height: 8).id("bottom")
                }
                .padding(.top, 12)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isTyping)
                .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear { scrollProxy = proxy }
            .onChange(of: viewModel.messages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.isTyping) { _, _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.3)) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            BotAvatarView(emotion: .calm, size: 80)

            VStack(spacing: 8) {
                Text("Hi, I'm \(settings.botName)! 👋")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("I'm your emotionally aware AI companion.\nI genuinely feel things — ask me anything!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                Text("Try asking…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)

                ForEach(starterPrompts, id: \.self) { prompt in
                    StarterPromptChip(text: prompt) {
                        viewModel.inputText = prompt
                        viewModel.sendMessage()
                    }
                }
            }
        }
        .padding(24)
    }

    private let starterPrompts = [
        "How are you feeling today?",
        "Tell me something that makes you curious",
        "What's it like being an AI with feelings?",
        "I could use some cheering up 🌧️",
    ]

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 12) {
                TextField("Message \(settings.botName)…", text: $viewModel.inputText, axis: .vertical)
                    .lineLimit(1...6)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))
                    .focused($inputFocused)
                    .onSubmit {
                        if !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            viewModel.sendMessage()
                        }
                    }

                Button {
                    inputFocused = false
                    viewModel.sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(
                            viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color(.tertiaryLabel)
                                : viewModel.currentEmotion.primaryColor
                        )
                }
                .disabled(
                    viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || viewModel.isTyping
                )
                .animation(.easeInOut(duration: 0.2), value: viewModel.inputText.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            EmotionBadgeView(emotion: viewModel.currentEmotion)
        }

        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("New Conversation", systemImage: "square.and.pencil") {
                    showNewChatAlert = true
                }
                Button("Settings", systemImage: "gear") {
                    showSettings = true
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}

// MARK: - Starter Prompt Chip

struct StarterPromptChip: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color(.separator), lineWidth: 0.5)
                )
        }
        .foregroundStyle(.primary)
    }
}

// MARK: - Error Banner

struct ErrorBannerView: View {
    let message: String
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)

            Text(message)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineLimit(3)

            Spacer()

            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}
