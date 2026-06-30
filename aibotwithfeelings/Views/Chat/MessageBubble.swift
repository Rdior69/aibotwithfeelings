import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 48)
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 6) {
                if let emotion = message.emotion, message.role == .assistant {
                    EmotionBadge(emotion: emotion)
                }

                Text(message.content)
                    .font(.body)
                    .foregroundStyle(message.role == .user ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(bubbleColor, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            if message.role == .assistant {
                Spacer(minLength: 48)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private var bubbleColor: Color {
        message.role == .user ? Color.accentColor : Color(.secondarySystemBackground)
    }

    private var accessibilityText: String {
        let speaker = message.role == .user ? "You" : "Assistant"
        if let emotion = message.emotion, message.role == .assistant {
            return "\(speaker), feeling \(emotion.displayName): \(message.content)"
        }
        return "\(speaker): \(message.content)"
    }
}

struct EmotionBadge: View {
    let emotion: Emotion

    var body: some View {
        Label(emotion.displayName, systemImage: emotion.symbolName)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.tertiarySystemFill), in: Capsule())
    }
}

#Preview {
    VStack(spacing: 12) {
        MessageBubble(message: ChatMessage(role: .assistant, content: "Hi, how are you feeling?", emotion: .empathetic))
        MessageBubble(message: ChatMessage(role: .user, content: "Pretty good today."))
    }
    .padding()
}
