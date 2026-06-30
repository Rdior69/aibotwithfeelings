import SwiftUI

struct ChatView: View {
    @Bindable var appModel: AppModel
    @State private var draft = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(appModel.chatService.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }

                            if appModel.chatService.isTyping {
                                TypingIndicator(name: appModel.profile.preferredBot.name)
                                    .id("typing")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: appModel.chatService.messages.count) {
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: appModel.chatService.isTyping) {
                        scrollToBottom(proxy: proxy)
                    }
                }

                Divider()

                HStack(spacing: 12) {
                    TextField("Share what's on your mind...", text: $draft, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(1...4)
                        .padding(12)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                        .accessibilityIdentifier("chatInputField")

                    Button {
                        send()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                    }
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || appModel.chatService.isTyping)
                    .accessibilityLabel("Send message")
                    .accessibilityIdentifier("sendMessageButton")
                }
                .padding()
            }
            .navigationTitle(appModel.profile.preferredBot.name)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Clear conversation", role: .destructive) {
                            appModel.chatService.clearConversation()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("Chat options")
                }
            }
            .onAppear {
                appModel.chatService.startConversationIfNeeded()
            }
        }
    }

    private func send() {
        let text = draft
        draft = ""
        Task {
            await appModel.chatService.sendMessage(text)
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            if appModel.chatService.isTyping {
                proxy.scrollTo("typing", anchor: .bottom)
            } else if let last = appModel.chatService.messages.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
}

private struct TypingIndicator: View {
    let name: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(name) is thinking...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ProgressView()
            }
            .padding(12)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
            Spacer(minLength: 48)
        }
        .accessibilityLabel("\(name) is typing")
    }
}

#Preview {
    ChatView(appModel: AppModel())
}
