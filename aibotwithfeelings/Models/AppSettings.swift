//
//  AppSettings.swift
//  aibotwithfeelings
//
//  Created by ray dior on 5/29/26.
//

import Foundation
import SwiftUI

@Observable
final class AppSettings {
    var botName: String {
        didSet { UserDefaults.standard.set(botName, forKey: Keys.botName) }
    }
    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.onboarding) }
    }
    var useHaptics: Bool {
        didSet { UserDefaults.standard.set(useHaptics, forKey: Keys.haptics) }
    }
    var showEmotionIndicator: Bool {
        didSet { UserDefaults.standard.set(showEmotionIndicator, forKey: Keys.showEmotion) }
    }
    var useAppleIntelligence: Bool {
        didSet { UserDefaults.standard.set(useAppleIntelligence, forKey: Keys.useAppleAI) }
    }
    var colorSchemePreference: ColorSchemePreference {
        didSet { UserDefaults.standard.set(colorSchemePreference.rawValue, forKey: Keys.colorScheme) }
    }

    init() {
        let d = UserDefaults.standard
        self.botName = d.string(forKey: Keys.botName) ?? "Aria"
        self.hasCompletedOnboarding = d.bool(forKey: Keys.onboarding)
        self.useHaptics = d.object(forKey: Keys.haptics) as? Bool ?? true
        self.showEmotionIndicator = d.object(forKey: Keys.showEmotion) as? Bool ?? true
        self.useAppleIntelligence = d.object(forKey: Keys.useAppleAI) as? Bool ?? true
        let schemeRaw = d.string(forKey: Keys.colorScheme) ?? ColorSchemePreference.system.rawValue
        self.colorSchemePreference = ColorSchemePreference(rawValue: schemeRaw) ?? .system
    }

    private enum Keys {
        static let botName    = "botName"
        static let onboarding = "hasCompletedOnboarding"
        static let haptics    = "useHaptics"
        static let showEmotion = "showEmotionIndicator"
        static let useAppleAI = "useAppleIntelligence"
        static let colorScheme = "colorSchemePreference"
    }

    enum ColorSchemePreference: String, CaseIterable {
        case system = "system"
        case light  = "light"
        case dark   = "dark"

        var displayName: String {
            switch self {
            case .system: return "System"
            case .light:  return "Light"
            case .dark:   return "Dark"
            }
        }

        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light:  return .light
            case .dark:   return .dark
            }
        }
    }
}
