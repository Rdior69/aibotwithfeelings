//
//  AppViewModel.swift
//  aibotwithfeelings
//

import Foundation
import Observation

@MainActor
@Observable
final class AppViewModel {
    private(set) var profile: UserProfile?
    private(set) var hasCompletedOnboarding: Bool

    let chatViewModel: ChatViewModel

    private let profileStore: LocalProfileStore

    init(
        profileStore: LocalProfileStore = LocalProfileStore(),
        aiService: AICompanionServing = MockAICompanionService(),
        memoryStore: CompanionMemoryStoring = InMemoryCompanionMemoryStore()
    ) {
        self.profileStore = profileStore

        if ProcessInfo.processInfo.arguments.contains("--uitest-reset-profile") {
            profileStore.clear()
        }

        if ProcessInfo.processInfo.arguments.contains("--uitest-seed-profile") {
            let seeded = UserProfile(
                preferredName: "Test User",
                preferredTone: .supportive,
                checkInEnabled: false,
                memoryEnabled: true
            )
            profileStore.save(seeded)
        }

        let loadedProfile = profileStore.load()
        self.profile = loadedProfile
        self.hasCompletedOnboarding = loadedProfile != nil
        self.chatViewModel = ChatViewModel(
            aiService: aiService,
            memoryStore: memoryStore,
            profile: loadedProfile
        )
    }

    func completeOnboarding(profile: UserProfile) {
        self.profile = profile
        hasCompletedOnboarding = true
        profileStore.save(profile)
        chatViewModel.updateProfile(profile)
    }

    func updateProfile(_ profile: UserProfile) {
        self.profile = profile
        profileStore.save(profile)
        chatViewModel.updateProfile(profile)
    }
}
