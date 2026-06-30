//
//  MessageBubble.swift
//  aibotwithfeelings
//

#if canImport(SwiftUI)
import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        switch message.sender {
        case .user:
            HStack {
                Spacer(minLength: 48)
                bubbleText
                    .foregroundStyle(.white)
                    .background(Theme.userBubble, in: bubbleShape)
            }
        case .bot:
            HStack(alignment: .bottom, spacing: 8) {
                Text(message.moodEmoji ?? "🙂")
                    .font(.title2)
                bubbleText
                    .background(.thinMaterial, in: bubbleShape)
                Spacer(minLength: 48)
            }
        case .system:
            HStack {
                bubbleText
                    .font(.callout)
                    .background(Theme.color(for: .calm).opacity(0.18), in: bubbleShape)
            }
        }
    }

    private var bubbleText: some View {
        Text(message.text)
            .font(.body)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var bubbleShape: some Shape {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
    }
}

/// Animated three-dot "bot is typing" indicator.
struct TypingIndicator: View {
    @State private var phase = 0.0

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Text("💭").font(.title2)
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .frame(width: 7, height: 7)
                        .opacity(opacity(for: i))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            Spacer(minLength: 48)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                phase = 1
            }
        }
    }

    private func opacity(for index: Int) -> Double {
        let base = 0.3 + 0.7 * abs(sin((phase * .pi) + Double(index) * 0.6))
        return min(1, base)
    }
}
#endif
