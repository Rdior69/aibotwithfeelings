import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 12) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(.tint)
                            .symbolRenderingMode(.hierarchical)

                        Text("Create Your Characters")
                            .font(.title.bold())

                        Text("Build up to \(SubscriptionConfig.maxCharacters) AI companions tailored exactly how you imagine them — appearance, personality, feelings, and voice.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 16) {
                        benefitRow(icon: "paintbrush.fill", title: "Fully Custom", detail: "Name, look, backstory, emotional style — yours.")
                        benefitRow(icon: "heart.fill", title: "Human Feelings", detail: "Characters that respond and feel like real people.")
                        benefitRow(icon: "antenna.radiowaves.left.and.right", title: "Live Intel", detail: "Same external modules that power Ava's edge.")
                        benefitRow(icon: "number", title: "Up to 20 Characters", detail: "Different moods, relationships, and personalities.")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))

                    VStack(spacing: 8) {
                        if case .trial(let days) = appState.accessTier {
                            Text("Your \(SubscriptionConfig.trialDays)-day trial: \(days) day\(days == 1 ? "" : "s") left")
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                            Text("Trial includes full Ava access. Subscribe to unlock character creation.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        } else if appState.accessTier == .expired {
                            Text("Your free trial has ended")
                                .font(.subheadline)
                                .foregroundStyle(.red)
                            Text("Subscribe to keep chatting and create custom characters.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        Text(appState.subscriptionManager.trialDescription)
                            .font(.headline)

                        Button {
                            Task {
                                let success = await appState.subscriptionManager.purchase()
                                if success {
                                    await appState.refreshAccess()
                                    dismiss()
                                }
                            }
                        } label: {
                            Group {
                                if appState.subscriptionManager.isLoading {
                                    ProgressView()
                                } else {
                                    Text("Start Premium — \(appState.subscriptionManager.priceDisplay)/mo")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(appState.subscriptionManager.isLoading)

                        Button("Restore Purchases") {
                            Task {
                                await appState.subscriptionManager.restore()
                                await appState.refreshAccess()
                                if appState.isPremium { dismiss() }
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

                    Text("Payment charged to Apple ID. Auto-renews monthly. Cancel anytime in Settings → Subscriptions.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func benefitRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(AppState())
}
