import SwiftUI

struct RootView: View {
    @Bindable var appModel: AppModel

    var body: some View {
        Group {
            if appModel.needsOnboarding {
                OnboardingView(appModel: appModel)
            } else {
                MainTabView(appModel: appModel)
            }
        }
        .animation(.easeInOut, value: appModel.needsOnboarding)
    }
}

#Preview {
    RootView(appModel: AppModel())
}
