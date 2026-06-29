import SwiftUI

struct RootView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        Group {
            if appState.needsOnboarding {
                OnboardingView()
            } else if appState.accessTier == .expired {
                ExpiredSubscriptionView()
            } else {
                mainTabs
            }
        }
        .environmentObject(appState)
        .sheet(isPresented: $appState.showPaywall) {
            PaywallView()
                .environmentObject(appState)
        }
        .task {
            await appState.refreshAccess()
        }
    }

    private var mainTabs: some View {
        TabView {
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
                }

            NavigationStack {
                CharacterListView()
            }
            .tabItem {
                Label("Characters", systemImage: "person.2.fill")
            }
        }
    }
}

/// Shown when a previous subscriber's subscription has lapsed.
struct ExpiredSubscriptionView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: 56))
                .foregroundStyle(.orange)

            Text("Your Subscription Ended")
                .font(.title.bold())

            Text("Resubscribe at \(SubscriptionConfig.monthlyPriceDisplay)/mo to keep chatting and access your custom characters.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                appState.showPaywall = true
            } label: {
                Text("Resubscribe")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Button("Restore Purchases") {
                Task {
                    await appState.subscriptionManager.restore()
                    await appState.refreshAccess()
                }
            }
            .font(.subheadline)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    RootView()
}
