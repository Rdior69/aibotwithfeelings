import SwiftUI

struct RootView: View {
    @StateObject private var appState = AppState()

    var body: some View {
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
        .environmentObject(appState)
        .sheet(isPresented: $appState.showPaywall) {
            PaywallView()
                .environmentObject(appState)
        }
        .task {
            await appState.refreshAccess()
        }
    }
}

#Preview {
    RootView()
}
