//
//  MessageBubbleView.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let botEmotion: EmotionState
    let botName: String

    @State private var appeared = false

    private var isUser: Bool { message.isFromUser }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if isUser {
                Spacer(minLength: 60)
            } else {
                BotAvatarView(emotion: message.emotion ?? botEmotion, size: 32)
                    .alignmentGuide(.bottom) { d in d[.bottom] }
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                if !isUser {
                    Text(botName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }

                Text(message.content)
                    .font(.body)
                    .foregroundStyle(isUser ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(bubbleBackground)
                    .clipShape(BubbleShape(isUser: isUser))

                HStack(spacing: 6) {
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if !isUser, let emotion = message.emotion {
                        EmotionBadgeView(emotion: emotion)
                    }
                }
                .padding(.horizontal, 4)
            }

            if !isUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 16)
        .scaleEffect(appeared ? 1.0 : 0.85)
        .opacity(appeared ? 1.0 : 0.0)
        .offset(y: appeared ? 0 : 10)
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                appeared = true
            }
        }
    }

    @ViewBuilder
    private var bubbleBackground: some View {
        if isUser {
            LinearGradient(
                colors: [Color.blue, Color(red: 0.2, green: 0.5, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            Color(.secondarySystemGroupedBackground)
        }
    }
}

// Custom bubble shape with different corner radii
struct BubbleShape: Shape {
    let isUser: Bool

    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 18
        let smallR: CGFloat = 4

        var path = Path()
        if isUser {
            path.addRoundedRect(
                in: rect,
                cornerRadii: RectangleCornerRadii(
                    topLeading: r, bottomLeading: r,
                    bottomTrailing: smallR, topTrailing: r
                )
            )
        } else {
            path.addRoundedRect(
                in: rect,
                cornerRadii: RectangleCornerRadii(
                    topLeading: smallR, bottomLeading: r,
                    bottomTrailing: r, topTrailing: r
                )
            )
        }
        return path
    }
}

#Preview {
    let userMsg = Message(content: "Hey Aria, how are you feeling today?", isFromUser: true)
    let botMsg = Message(content: "I'm feeling wonderfully curious! 🤔 Something about today's conversations has sparked a real sense of wonder in me.", isFromUser: false, emotion: .curious)

    ScrollView {
        VStack(spacing: 12) {
            MessageBubbleView(message: userMsg, botEmotion: .calm, botName: "Aria")
            MessageBubbleView(message: botMsg, botEmotion: .curious, botName: "Aria")
        }
        .padding(.vertical)
    }
    .background(Color(.systemGroupedBackground))
}
