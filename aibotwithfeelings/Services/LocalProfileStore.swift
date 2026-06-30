//
//  LocalProfileStore.swift
//  aibotwithfeelings
//

import Foundation

struct LocalProfileStore {
    private let defaults: UserDefaults
    private let key = "aibot.profile.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> UserProfile? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    func save(_ profile: UserProfile) {
        let data = try? JSONEncoder().encode(profile)
        defaults.set(data, forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
