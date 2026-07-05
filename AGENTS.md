# AGENTS.md

## Project overview

`aibotwithfeelings` is a **native Apple SwiftUI companion app** (iOS / iPadOS / macOS / visionOS). It provides onboarding, chat, emotional state tracking, in-memory key-moment storage, and local profile persistence. The AI layer is currently backed by `MockAICompanionService` with a protocol (`AICompanionServing`) ready for a production provider.

- Pure client app — no backend or containers in this repo.
- Build system: Xcode project `aibotwithfeelings.xcodeproj` plus root-level `Package.swift` for headless core testing.
- Source layout: app code in `aibotwithfeelings/` (`Models/`, `Services/`, `ViewModels/`, `Views/`); tests in `aibotwithfeelingsTests/` (XCTest) and `aibotwithfeelingsUITests/`, plus `Tests/AIBotCompanionCoreTests/` (Swift Testing via SPM).

## Building / running / testing (macOS only)

The full app **requires macOS + Xcode** with Apple SDKs.

- Run: open `aibotwithfeelings.xcodeproj` in Xcode and Run (⌘R) on a simulator or device.
- CLI test (macOS, iOS Simulator):
  ```bash
  xcodebuild test \
    -project aibotwithfeelings.xcodeproj \
    -scheme aibotwithfeelings \
    -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5' \
    -only-testing:aibotwithfeelingsTests
  ```

## Linux / Cloud Agent VM

The Cloud Agent VM is **Linux**, so the SwiftUI app **cannot be built or run here**. What you can do on this VM:

- Build and test the Foundation-only core via SPM:
  ```bash
  swift build --target AIBotCompanionCore
  swift test --filter AIBotCompanionCoreTests
  ```
- Swift 6.1 for Linux is pre-installed (`swift --version` in a login shell).

Apple-framework files (`ViewModels/`, `Views/`, `ContentView.swift`, `aibotwithfeelingsApp.swift`) are excluded from the `AIBotCompanionCore` SPM target and only compile on Apple platforms.

## Repository layout

| Path | Purpose |
|------|---------|
| `Package.swift` | SPM manifest — `AIBotCompanionCore` and core tests (UI stays in Xcode only) |
| `aibotwithfeelings.xcodeproj/xcshareddata/xcschemes/` | Shared scheme for CI and CLI |
| `.github/workflows/swift.yml` | Linux core tests + iOS Simulator `xcodebuild test` |
| `Tests/AIBotCompanionCoreTests/` | SPM-compatible unit tests (mirrors Xcode tests) |

## CI

GitHub Actions runs two jobs on every push/PR to `main`:

1. **linux-core-tests** — `swift test` against `AIBotCompanionCore`
2. **ios-xcode-tests** — `xcodebuild test` on iOS Simulator with the shared `aibotwithfeelings` scheme

See [CONTRIBUTING.md](CONTRIBUTING.md) and [ROADMAP.md](ROADMAP.md) for workflow and milestones.
