import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            Section("Access") {
                settingsRow(
                    icon: "checkmark.seal.fill",
                    title: "Current plan",
                    value: appState.accessTier.displayLabel
                )

                settingsRow(
                    icon: "person.2.fill",
                    title: "Custom characters",
                    value: "\(appState.characterStore.customCharacters.count)/\(SubscriptionConfig.maxCharacters)"
                )

                Button {
                    appState.showPaywall = true
                } label: {
                    Label(appState.isPremium ? "Manage Premium" : "View Trial and Premium", systemImage: "sparkles")
                }

                Button {
                    Task {
                        await appState.subscriptionManager.restore()
                        await appState.refreshAccess()
                    }
                } label: {
                    Label("Restore Purchases", systemImage: "arrow.clockwise")
                }
            }

            Section("AI Configuration") {
                settingsRow(
                    icon: "key.fill",
                    title: "Gemini key",
                    value: AvaConfig.hasAPIKey ? "Configured" : "Offline fallback"
                )

                settingsRow(
                    icon: "cpu.fill",
                    title: "Gemini model",
                    value: AvaConfig.geminiModel
                )

                settingsRow(
                    icon: "network",
                    title: "Live intel modules",
                    value: AvaToolKind.allCases.map(\.rawValue).joined(separator: ", ")
                )
            }

            Section("Safety and Privacy") {
                settingsRow(
                    icon: "exclamationmark.shield.fill",
                    title: "Crisis boundary",
                    value: "High-risk self-harm messages show immediate support resources."
                )

                settingsRow(
                    icon: "lock.shield.fill",
                    title: "Storage",
                    value: "Characters are stored locally. Chat history persistence is not implemented yet."
                )

                settingsRow(
                    icon: "globe",
                    title: "External services",
                    value: "Gemini and live intel APIs may receive chat text when enabled."
                )
            }

            if let error = appState.subscriptionManager.purchaseError {
                Section("StoreKit Status") {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Settings")
    }

    private func settingsRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.tint)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppState())
    }
}
