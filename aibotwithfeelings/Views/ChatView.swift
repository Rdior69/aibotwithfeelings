//
//  ChatView.swift
//  aibotwithfeelings
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your companion is ready")
                    .font(.headline)
                    .accessibilityIdentifier("chat.title")
                Text("Current tone: \(viewModel.currentEmotion.label.rawValue.capitalized)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }

                        if viewModel.isResponding {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Companion is thinking...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 12)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastID = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 8) {
                TextField("Tell me what is on your mind...", text: $viewModel.draft, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .accessibilityIdentifier("chat.composerField")

                Button("Send") {
                    Task {
                        await viewModel.sendCurrentMessage()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isResponding)
                .accessibilityIdentifier("chat.sendButton")
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }
}

private struct MessageBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }

            Text(message.text)
                .font(.body)
                .foregroundStyle(foregroundColor)
                .padding(12)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .frame(maxWidth: 300, alignment: message.role == .user ? .trailing : .leading)

            if message.role != .user {
                Spacer()
            }
        }
        .padding(.horizontal)
    }

    private var backgroundColor: Color {
        if message.isError {
            return Color.red.opacity(0.16)
        }

        switch message.role {
        case .user:
            return Color.accentColor.opacity(0.2)
        case .companion:
            return Color.gray.opacity(0.15)
        case .system:
            return Color.orange.opacity(0.14)
        }
    }

    private var foregroundColor: Color {
        message.isError ? .red : .primary
    }
}

#Preview {
    ChatView(
        viewModel: ChatViewModel(
            aiService: MockAICompanionService(),
            memoryStore: InMemoryCompanionMemoryStore(),
            profile: UserProfile.empty
        )
    )
}
