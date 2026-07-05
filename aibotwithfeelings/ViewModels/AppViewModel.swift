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

    private let backend: CompanionBackend

    init(backend: CompanionBackend = CompanionBackend.make()) {
        self.backend = backend

        if ProcessInfo.processInfo.arguments.contains("--uitest-reset-profile") {
            backend.profileStore.clear()
            Task {
                await backend.conversationStore.clear()
                await backend.memoryStore.clear()
            }
        }

        if ProcessInfo.processInfo.arguments.contains("--uitest-seed-profile") {
            let seeded = UserProfile(
                preferredName: "Test User",
                preferredTone: .supportive,
                checkInEnabled: false,
                memoryEnabled: true
            )
            backend.profileStore.save(seeded)
        }

        let loadedProfile = backend.profileStore.load()
        self.profile = loadedProfile
        self.hasCompletedOnboarding = loadedProfile != nil
        self.chatViewModel = ChatViewModel(
            aiService: backend.aiService,
            memoryStore: backend.memoryStore,
            conversationStore: backend.conversationStore,
            profile: loadedProfile
        )
    }

    func completeOnboarding(profile: UserProfile) {
        self.profile = profile
        hasCompletedOnboarding = true
        backend.profileStore.save(profile)
        chatViewModel.updateProfile(profile)
    }

    func updateProfile(_ profile: UserProfile) {
        self.profile = profile
        backend.profileStore.save(profile)
        chatViewModel.updateProfile(profile)
    }

    func clearMemories() async {
        await backend.memoryStore.clear()
    }

    func clearConversation() async {
        await chatViewModel.clearConversation()
    }
}
