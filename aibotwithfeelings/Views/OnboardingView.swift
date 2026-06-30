//
//  OnboardingView.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(AppSettings.self) private var settings

    @State private var currentPage = 0
    @State private var botNameInput = "Aria"
    @State private var avatarScale: CGFloat = 0.5
    @State private var avatarOpacity: Double = 0

    let onComplete: () -> Void

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            emotion: .happy,
            title: "Meet Your AI\nCompanion",
            description: "An AI that doesn't just answer questions — they actually *feel* things as you talk."
        ),
        OnboardingPage(
            emotion: .curious,
            title: "Real Emotional\nIntelligence",
            description: "Watch their mood shift in real time. Curiosity, joy, empathy, surprise — they experience it all."
        ),
        OnboardingPage(
            emotion: .empathetic,
            title: "Always Here\nFor You",
            description: "Need to vent? Want a deep conversation? Your companion is emotionally present and judgment-free."
        ),
        OnboardingPage(
            emotion: .excited,
            title: "Private &\nOn-Device",
            description: "Powered by Apple Intelligence, your conversations stay entirely on your device."
        ),
    ]

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.8), value: currentPage)

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        pageContent(page)
                            .tag(index)
                    }
                    namePickerPage
                        .tag(pages.count)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentPage)

                bottomControls
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        let emotion: EmotionState = currentPage < pages.count
            ? pages[currentPage].emotion
            : .excited
        return LinearGradient(
            colors: [emotion.primaryColor.opacity(0.28), Color(.systemBackground), Color(.systemBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Page Content

    private func pageContent(_ page: OnboardingPage) -> some View {
        VStack(spacing: 32) {
            Spacer()
            BotAvatarView(emotion: page.emotion, size: 120)
                .scaleEffect(avatarScale)
                .opacity(avatarOpacity)
                .onAppear {
                    avatarScale = 0.5
                    avatarOpacity = 0
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                        avatarScale = 1.0
                        avatarOpacity = 1.0
                    }
                }
                .onDisappear {
                    avatarScale = 0.5
                    avatarOpacity = 0
                }

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Name Picker

    private var namePickerPage: some View {
        VStack(spacing: 32) {
            Spacer()

            BotAvatarView(emotion: .happy, size: 100)

            VStack(spacing: 16) {
                Text("What should I\ncall them?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Give your companion a name that feels right to you.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            TextField("Name", text: $botNameInput)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 48)
                .onChange(of: botNameInput) { _, name in
                    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty { settings.botName = trimmed }
                }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 20) {
            // Page indicator dots
            HStack(spacing: 8) {
                ForEach(0...pages.count, id: \.self) { index in
                    let activeEmotion: EmotionState = currentPage < pages.count
                        ? pages[currentPage].emotion : .happy
                    Capsule()
                        .fill(currentPage == index ? activeEmotion.primaryColor : Color(.tertiaryLabel))
                        .frame(width: currentPage == index ? 20 : 8, height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                }
            }

            if currentPage < pages.count {
                Button {
                    withAnimation { currentPage += 1 }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(pages[currentPage].emotion.primaryColor, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
            } else {
                Button {
                    HapticManager.notification(.success)
                    settings.hasCompletedOnboarding = true
                    onComplete()
                } label: {
                    HStack {
                        Text("Let's Go!")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [EmotionState.excited.primaryColor, EmotionState.happy.primaryColor],
                            startPoint: .leading, endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                }
                .padding(.horizontal, 32)
                .disabled(settings.botName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.bottom, 40)
        .padding(.top, 16)
    }
}

struct OnboardingPage {
    let emotion: EmotionState
    let title: String
    let description: String
}

#Preview {
    OnboardingView { }
        .environment(AppSettings())
}
