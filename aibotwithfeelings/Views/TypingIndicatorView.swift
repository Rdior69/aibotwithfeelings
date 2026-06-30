//
//  TypingIndicatorView.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import SwiftUI

struct TypingIndicatorView: View {
    let emotion: EmotionState

    @State private var animating = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            BotAvatarView(emotion: emotion, size: 32, isTyping: true)

            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(emotion.primaryColor)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animating ? 1.3 : 0.7)
                        .opacity(animating ? 1.0 : 0.4)
                        .animation(
                            .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.18),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )

            Spacer()
        }
        .padding(.horizontal, 16)
        .onAppear { animating = true }
        .onDisappear { animating = false }
    }
}

#Preview {
    VStack(spacing: 16) {
        ForEach([EmotionState.happy, .empathetic, .excited, .thoughtful], id: \.self) { e in
            TypingIndicatorView(emotion: e)
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
