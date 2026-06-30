//
//  BotAvatarView.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import SwiftUI

struct BotAvatarView: View {
    let emotion: EmotionState
    let size: CGFloat
    var isTyping: Bool = false

    @State private var isPulsing = false
    @State private var isWiggling = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [emotion.primaryColor, emotion.secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: emotion.primaryColor.opacity(0.4), radius: isPulsing ? 12 : 4, x: 0, y: 2)
                .scaleEffect(isPulsing ? 1.04 : 1.0)

            Text(emotion.emoji)
                .font(.system(size: size * 0.48))
                .rotationEffect(.degrees(isWiggling ? -8 : 8))
        }
        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: isPulsing)
        .animation(
            isTyping
                ? .easeInOut(duration: 0.35).repeatForever(autoreverses: true)
                : .default,
            value: isWiggling
        )
        .onChange(of: isTyping) { _, typing in
            isWiggling = typing
        }
        .onChange(of: emotion) { _, _ in
            // Brief pulse on emotion change
            withAnimation(.easeOut(duration: 0.15)) { isPulsing = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
        }
        .onAppear {
            isPulsing = true
        }
    }
}

// MARK: - Compact emotion badge for message rows

struct EmotionBadgeView: View {
    let emotion: EmotionState

    var body: some View {
        HStack(spacing: 4) {
            Text(emotion.emoji)
                .font(.caption2)
            Text(emotion.displayName)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(emotion.primaryColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(emotion.primaryColor.opacity(0.15), in: Capsule())
    }
}

#Preview {
    VStack(spacing: 24) {
        ForEach(EmotionState.allCases) { emotion in
            HStack {
                BotAvatarView(emotion: emotion, size: 56)
                EmotionBadgeView(emotion: emotion)
            }
        }
    }
    .padding()
}
