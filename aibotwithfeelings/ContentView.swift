//
//  ContentView.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @State private var isShowingSettings = false

    var body: some View {
        Group {
            if appViewModel.hasCompletedOnboarding {
                NavigationStack {
                    ChatView(viewModel: appViewModel.chatViewModel)
                        .navigationTitle("AIBot With Feelings")
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    isShowingSettings = true
                                } label: {
                                    Image(systemName: "gearshape")
                                }
                                .accessibilityIdentifier("chat.settingsButton")
                            }
                        }
                }
                .sheet(isPresented: $isShowingSettings) {
                    SettingsView(appViewModel: appViewModel)
                }
            } else {
                OnboardingView(appViewModel: appViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
