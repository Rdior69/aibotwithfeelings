# AGENTS.md

## Project overview

`aibotwithfeelings` ("Ava") is a **native Apple SwiftUI app** (iOS / iPadOS / macOS / visionOS, deployment target 26.5). Ava is an emotionally-expressive AI companion: chat is powered by Google **Gemini**, an `IntentAnalyzer` decides when to enrich replies with live data from external HTTPS modules (weather, news, web search, Wikipedia, quotes, creative prompts), and premium users (StoreKit 2 subscription) can create custom characters.

- Pure client app — **no backend, database, or containers** in this repo. State persists in `UserDefaults`; third-party APIs are called directly over HTTPS.
- Build system: Xcode project `aibotwithfeelings.xcodeproj` (no SPM/CocoaPods/Carthage — **zero third-party package dependencies**).
- Source layout: app code in `aibotwithfeelings/` (`Ava/Models`, `Ava/Services`, `Ava/Services/Tools`, `Ava/Views`, `Ava/ViewModels`, `Ava/Config`, `Ava/Personality`); tests in `aibotwithfeelingsTests/` (XCTest) and `aibotwithfeelingsUITests/`.

## Building / running / testing (macOS only)

This app **requires macOS + Xcode 26.5+** with Apple SDKs. There are no package-manager dependencies to install — just open and run.

- Run: open `aibotwithfeelings.xcodeproj` in Xcode and Run (⌘R) on a simulator/device.
- CLI build/test (macOS): `xcodebuild -project aibotwithfeelings.xcodeproj -scheme aibotwithfeelings -destination 'platform=iOS Simulator,name=iPhone 16' build` / `test`.
- Config before full chat works: set `GEMINI_API_KEY` in `aibotwithfeelings/Info.plist` (replacing `YOUR_GEMINI_API_KEY_HERE`) or as a run-scheme env var (see `aibotwithfeelings/Ava/Config/AvaConfig.swift`); optionally set `GEMINI_MODEL` if your key has quota for a specific Gemini model. Enable the bundled `aibotwithfeelings/Products.storekit` as the scheme's StoreKit configuration for trial/subscription testing. Without a key the app falls back to an offline synthesis path that still calls the live external modules.

## Cursor Cloud specific instructions

The Cloud Agent VM is **Linux**, so the actual app **cannot be built, run, or UI-tested here** — `xcodebuild`, SwiftUI, UIKit, StoreKit, and the iOS/visionOS simulators only exist on macOS. There is no GUI app to drive with computer-use; demonstrate via terminal/logs instead. Full `xcodebuild build`/`test` and the `aibotwithfeelingsTests`/`aibotwithfeelingsUITests` targets require macOS + Xcode and are out of scope on this VM.

What you CAN do on this VM: the Foundation-only core "brain" (intent analysis + live external-intel modules + offline synthesis) runs under **open-source Swift 6.1 for Linux**, which is pre-installed at `~/swift-6.1` and added to `PATH` via `~/.bashrc` (`swift --version` should work in a login shell). Apple-framework files are excluded from this path: `Services/SubscriptionManager.swift` (StoreKit), `Services/CharacterStore.swift` and `Services/AvaBrain.swift` (Combine `ObservableObject`/`@MainActor`), and all of `Ava/Views`/`Ava/ViewModels`/`ContentView`/`aibotwithfeelingsApp`/`Products.storekit`.

A throwaway Linux harness lives at `~/ava-cli-demo` (NOT part of the repo; do not commit it). It copies the Foundation-only source files and adds a small `main.swift` that mirrors `AvaBrain`'s orchestration. To rebuild/run:
```
cd ~/ava-cli-demo && swiftc -swift-version 5 src/*.swift -o ava && ./ava
```
Non-obvious caveats when running Swift code on Linux (these differences are why the harness keeps adjusted copies rather than the originals; they do NOT indicate app bugs on the real Apple toolchain):
- `URLSession` is in the separate `FoundationNetworking` module on Linux — add `#if canImport(FoundationNetworking)\nimport FoundationNetworking\n#endif` to any file that uses it.
- `String.split(separator: " ")`/`joined` resolve to different overloads under Swift 6.1; disambiguating (`split(separator: " " as Character).map(String.init)`) is needed in `IntentAnalyzer` on Linux.
- `Services/CharacterPromptBuilder.swift` calls a local closure with argument labels (`traitLabel(..., low:, high:)`) in its custom-character branch, which open-source `swiftc` rejects; it is excluded from the Linux harness (built-in Ava uses `AvaPersonality.systemPrompt` directly). This only affects the non-built-in code path; verify on the real Xcode toolchain before treating it as a fix target.

To exercise the full Gemini synthesis path (not just offline fallback), provide a `GEMINI_API_KEY` (env var is picked up by `AvaConfig`); without it the live weather/news/Wikipedia/quote modules still run and the app uses offline synthesis. Two non-obvious gotchas observed when wiring up the key:
- `AvaConfig` reads the env var named exactly `GEMINI_API_KEY`. On the Cloud VM the secret is injected under its secret name, so the secret must be named `GEMINI_API_KEY` (not, e.g., the repo name) for `AvaConfig` to find it — otherwise map it manually for the harness (`GEMINI_API_KEY="$othername" ./ava`).
- The default model is `gemini-flash-latest`. A standard AI-Studio key's project can return `Quota exceeded ... limit: 0` for some pinned models while `gemini-flash-latest` / `gemini-2.5-flash` work with the same key. If chat fails with a quota error, the key is fine — the model/billing is the issue (enable billing/quota for that model, or set `GEMINI_MODEL` to an available model).
