import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private var isTrialActive: Bool { appState.isInTrial }
    private var isExpired: Bool { appState.accessTier == .expired }
    private var needsStart: Bool { appState.accessTier == .none }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    benefitsSection
                    actionSection
                    legalSection
                }
                .padding()
            }
            .navigationTitle(isTrialActive ? "Your Trial" : "Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !needsStart {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: isTrialActive ? "sparkles" : "person.3.fill")
                .font(.system(size: 52))
                .foregroundStyle(.tint)
                .symbolRenderingMode(.hierarchical)

            Text(headerTitle)
                .font(.title.bold())

            Text(headerSubtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var headerTitle: String {
        if isTrialActive { return "Free Trial Active" }
        if isExpired { return "Welcome Back" }
        if needsStart { return "Start Your Free Trial" }
        return "Create Your Characters"
    }

    private var headerSubtitle: String {
        if isTrialActive {
            return "You're chatting with Ava. Custom characters unlock automatically when your trial converts to premium at \(SubscriptionConfig.monthlyPriceDisplay)/mo."
        }
        if isExpired {
            return "Resubscribe to keep chatting and access your custom characters."
        }
        return "Build up to \(SubscriptionConfig.maxCharacters) AI companions tailored exactly how you imagine them."
    }

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isTrialActive, case .trial(let days) = appState.accessTier {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.orange)
                    Text(days == 1 ? "1 day left in your free trial" : "\(days) days left in your free trial")
                        .font(.subheadline.bold())
                }
                .padding(.bottom, 4)
            }

            benefitRow(icon: "heart.fill", title: "Human Feelings", detail: "Characters that respond and feel like real people.")
            benefitRow(icon: "paintbrush.fill", title: "Fully Custom", detail: "Name, look, backstory, emotional style — yours.")
            benefitRow(icon: "antenna.radiowaves.left.and.right", title: "Live Intel", detail: "Same external modules that power Ava's edge.")
            benefitRow(icon: "number", title: "Up to 20 Characters", detail: "Different moods, relationships, and personalities.")
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private var actionSection: some View {
        VStack(spacing: 8) {
            if !isTrialActive {
                Text(appState.subscriptionManager.trialDescription)
                    .font(.headline)

                Button {
                    Task {
                        let success = await appState.subscriptionManager.startTrial()
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
                            Text(primaryButtonTitle)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(appState.subscriptionManager.isLoading)
            }

            Button("Restore Purchases") {
                Task {
                    await appState.subscriptionManager.restore()
                    await appState.refreshAccess()
                    if appState.canChat { dismiss() }
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
    }

    private var primaryButtonTitle: String {
        if isExpired { return "Resubscribe — \(appState.subscriptionManager.priceDisplay)/mo" }
        return appState.subscriptionManager.startTrialButtonTitle
    }

    private var legalSection: some View {
        Text("Payment charged to Apple ID after the \(SubscriptionConfig.trialDays)-day trial. Auto-renews monthly at \(SubscriptionConfig.monthlyPriceDisplay). Cancel anytime in Settings → Subscriptions.")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
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
