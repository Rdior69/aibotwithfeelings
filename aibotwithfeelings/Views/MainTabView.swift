import SwiftUI

struct MainTabView: View {
    @Bindable var appModel: AppModel

    var body: some View {
        TabView {
            ChatView(appModel: appModel)
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .accessibilityIdentifier("chatTab")

            MemoriesView(appModel: appModel)
                .tabItem {
                    Label("Memories", systemImage: "brain.head.profile")
                }
                .accessibilityIdentifier("memoriesTab")

            SettingsView(appModel: appModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .accessibilityIdentifier("settingsTab")
        }
    }
}

#Preview {
    MainTabView(appModel: AppModel())
}
