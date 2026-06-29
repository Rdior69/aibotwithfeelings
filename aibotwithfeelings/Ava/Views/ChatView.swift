import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool

    private var character: AICharacter {
        appState.characterStore.activeCharacter
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !appState.canChat {
                    expiredBanner
                }

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message, characterName: character.name)
                                    .id(message.id)
                            }

                            AvaThinkingView(phase: viewModel.thinkingPhase)
                                .id("thinking")
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: viewModel.thinkingPhase) { _, _ in
                        scrollToBottom(proxy: proxy)
                    }
                }

                Divider()

                HStack(spacing: 12) {
                    TextField("Talk to \(character.name)...", text: $viewModel.inputText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(1...5)
                        .focused($isInputFocused)
                        .disabled(!appState.canChat)
                        .onSubmit { send() }

                    Button(action: send) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .disabled(
                        viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || viewModel.isProcessing
                        || !appState.canChat
                    )
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.bar)
            }
            .navigationTitle(character.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("\(character.avatarEmoji) \(character.name)")
                            .font(.headline)
                        Text(appState.accessTier.displayLabel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onAppear {
                viewModel.loadConversation(for: character)
            }
            .onChange(of: character.id) { _, _ in
                viewModel.loadConversation(for: character)
            }
        }
    }

    private var expiredBanner: some View {
        Button {
            appState.showPaywall = true
        } label: {
            HStack {
                Image(systemName: "lock.fill")
                Text("Trial ended — Resubscribe to keep chatting")
                    .font(.subheadline.bold())
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange.opacity(0.15))
        }
        .buttonStyle(.plain)
    }

    private func send() {
        guard appState.requireChatAccess() else { return }
        Task {
            await viewModel.send(
                character: character,
                canChat: appState.canChat
            )
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.25)) {
            if viewModel.thinkingPhase != .idle {
                proxy.scrollTo("thinking", anchor: .bottom)
            } else if let last = viewModel.messages.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
}

#Preview {
    ChatView()
        .environmentObject(AppState())
}
