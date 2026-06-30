//
//  ContentView.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppSettings.self) private var settings

    @State private var showOnboarding = false

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showOnboarding = false
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            } else {
                ChatView(settings: settings)
                    .transition(.opacity)
            }
        }
        .onAppear {
            showOnboarding = !settings.hasCompletedOnboarding
        }
        .preferredColorScheme(settings.colorSchemePreference.colorScheme)
    }
}

#Preview {
    ContentView()
        .environment(AppSettings())
        .modelContainer(for: Message.self, inMemory: true)
}
