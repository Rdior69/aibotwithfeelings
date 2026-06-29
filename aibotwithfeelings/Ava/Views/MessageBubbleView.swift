import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom) {
            if isUser { Spacer(minLength: 48) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 6) {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(isUser ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(isUser ? Color.accentColor : Color(.secondarySystemBackground))
                    )

                if !message.toolsUsed.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.caption2)
                        Text(message.toolsUsed.joined(separator: " · "))
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                }
            }

            if !isUser { Spacer(minLength: 48) }
        }
    }
}
