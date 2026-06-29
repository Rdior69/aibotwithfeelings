import SwiftUI

/// First-launch screen — starts the unified StoreKit 5-day free trial.
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)

                VStack(spacing: 16) {
                    Text("✨")
                        .font(.system(size: 72))

                    Text("Meet Ava")
                        .font(.largeTitle.bold())

                    Text("An AI that feels human — real emotions, real reactions, zero echo-chamber nonsense.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 20) {
                    onboardingRow(
                        icon: "gift.fill",
                        title: "\(SubscriptionConfig.trialDays)-Day Free Trial",
                        detail: "Full Ava access. Talk freely — she responds with genuine human feeling."
                    )
                    onboardingRow(
                        icon: "person.fill",
                        title: "Then \(SubscriptionConfig.monthlyPriceDisplay)/month",
                        detail: "Unlock up to \(SubscriptionConfig.maxCharacters) custom characters tailored exactly how you imagine them."
                    )
                    onboardingRow(
                        icon: "arrow.triangle.2.circlepath",
                        title: "One seamless flow",
                        detail: "Your trial rolls into premium automatically. Cancel anytime in Settings."
                    )
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))

                VStack(spacing: 12) {
                    Button {
                        Task {
                            let success = await appState.subscriptionManager.startTrial()
                            if success {
                                await appState.refreshAccess()
                            }
                        }
                    } label: {
                        Group {
                            if appState.subscriptionManager.isLoading {
                                ProgressView()
                            } else {
                                Text(appState.subscriptionManager.startTrialButtonTitle)
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)

                    Text(appState.subscriptionManager.trialDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button("Restore Purchases") {
                        Task {
                            await appState.subscriptionManager.restore()
                            await appState.refreshAccess()
                        }
                    }
                    .font(.subheadline)

                    if let error = appState.subscriptionManager.purchaseError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }
                }

                Text("Payment method required. You won't be charged until the \(SubscriptionConfig.trialDays)-day trial ends. Auto-renews at \(SubscriptionConfig.monthlyPriceDisplay)/mo.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 20)
            }
            .padding()
        }
    }

    private func onboardingRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
