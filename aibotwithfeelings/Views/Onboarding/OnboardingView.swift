import SwiftUI

struct OnboardingView: View {
    @Bindable var appModel: AppModel
    @State private var step = 0
    @State private var displayName = ""
    @State private var selectedBot = BotPersonality.defaultBot

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("Welcome to \(AppTheme.botName)")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text("A companion that remembers how you feel and grows with you.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Group {
                switch step {
                case 0:
                    nameStep
                default:
                    personalityStep
                }
            }
            .animation(.easeInOut, value: step)

            Spacer()

            HStack {
                if step > 0 {
                    Button("Back") {
                        step -= 1
                    }
                }

                Spacer()

                Button(step == 0 ? "Continue" : "Start chatting") {
                    if step == 0 {
                        step = 1
                    } else {
                        appModel.completeOnboarding(displayName: displayName, bot: selectedBot)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(step == 0 && displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier(step == 0 ? "onboardingContinueButton" : "onboardingStartButton")
            }
        }
        .padding(24)
    }

    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What should I call you?")
                .font(.title3.bold())

            TextField("Your name", text: $displayName)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)
                .accessibilityIdentifier("onboardingNameField")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var personalityStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose your companion")
                .font(.title3.bold())

            ForEach(BotPersonality.presets, id: \.name) { bot in
                Button {
                    selectedBot = bot
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: selectedBot.name == bot.name ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(Color.accentColor)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(bot.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(bot.toneDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(selectedBot.name == bot.name ? Color.accentColor : Color(.separator), lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("botPreset_\(bot.name)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    OnboardingView(appModel: AppModel())
}
