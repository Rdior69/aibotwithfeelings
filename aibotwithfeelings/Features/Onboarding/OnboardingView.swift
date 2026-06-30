//
//  OnboardingView.swift
//  aibotwithfeelings
//
//  First-run flow: introduces the app, collects the user's name, lets them name
//  their companion and pick a personality.
//

#if canImport(SwiftUI)
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState

    @State private var step = 0
    @State private var displayName = ""
    @State private var botName = "Ava"
    @State private var personalityID = Personality.default.id

    private let lastStep = 2

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.color(for: .affection).opacity(0.25),
                         Theme.color(for: .calm).opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer(minLength: 12)

                content

                Spacer()

                controls
            }
            .padding(24)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case 0: welcomeStep
        case 1: nameStep
        default: personalityStep
        }
    }

    private var welcomeStep: some View {
        VStack(spacing: 18) {
            Text("🤖💛")
                .font(.system(size: 72))
            Text("AI Bot With Feelings")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text("A caring AI companion that remembers what matters to you and grows with every conversation.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .transition(.opacity)
    }

    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Let's get acquainted")
                .font(.title.bold())
            VStack(alignment: .leading, spacing: 8) {
                Text("What should I call you?")
                    .font(.headline)
                TextField("Your name", text: $displayName)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.next)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("And what would you like to name me?")
                    .font(.headline)
                TextField("Companion name", text: $botName)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .transition(.opacity)
    }

    private var personalityStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pick \(botName.isEmpty ? "my" : "\(botName)'s") personality")
                .font(.title.bold())
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Personality.presets) { preset in
                        PersonalityCard(
                            personality: preset,
                            isSelected: preset.id == personalityID
                        )
                        .onTapGesture {
                            withAnimation { personalityID = preset.id }
                        }
                    }
                }
            }
        }
        .transition(.opacity)
    }

    private var controls: some View {
        HStack {
            if step > 0 {
                Button("Back") {
                    withAnimation { step -= 1 }
                }
                .buttonStyle(.bordered)
            }
            Spacer()
            Button(step == lastStep ? "Start chatting" : "Continue") {
                if step == lastStep {
                    appState.completeOnboarding(
                        displayName: displayName,
                        botName: botName,
                        personalityID: personalityID
                    )
                } else {
                    withAnimation { step += 1 }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(step == 1 && displayName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}

struct PersonalityCard: View {
    let personality: Personality
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 14) {
            Text(personality.emoji)
                .font(.system(size: 34))
            VStack(alignment: .leading, spacing: 4) {
                Text(personality.displayName)
                    .font(.headline)
                Text(personality.tagline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.tint)
                    .font(.title2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.corner)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.corner)
                .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
#endif
