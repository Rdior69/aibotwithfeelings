//
//  ChatView.swift
//  aibotwithfeelings
//
//  The main conversation screen: mood header, scrolling transcript, animated
//  typing indicator and an input bar.
//

#if canImport(SwiftUI)
import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.colorScheme) private var scheme
    @State private var draft = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        ZStack {
            Theme.backgroundGradient(for: appState.mood.dominant, scheme: scheme)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.8), value: appState.mood.dominant)

            VStack(spacing: 0) {
                MoodHeaderView(botName: appState.profile.botName, mood: appState.mood)
                    .background(.ultraThinMaterial)

                transcript

                inputBar
            }
        }
    }

    private var transcript: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(appState.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    if appState.isTyping {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .onChange(of: appState.messages.count) {
                scrollToBottom(proxy)
            }
            .onChange(of: appState.isTyping) {
                scrollToBottom(proxy)
            }
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.25)) {
            if appState.isTyping {
                proxy.scrollTo("typing", anchor: .bottom)
            } else if let last = appState.messages.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Share what's on your mind…", text: $draft, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.thinMaterial, in: Capsule())
                .focused($inputFocused)
                .onSubmit(sendDraft)

            Button(action: sendDraft) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .symbolRenderingMode(.hierarchical)
            }
            .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty || appState.isTyping)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private func sendDraft() {
        let text = draft
        draft = ""
        appState.send(text)
    }
}

#Preview {
    ChatView()
        .environmentObject(AppState())
}
#endif
