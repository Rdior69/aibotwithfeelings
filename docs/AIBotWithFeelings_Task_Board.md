# AIBotWithFeelings Task Board

This board captures the current audit and next build priorities. It treats the existing Ava implementation as the foundation to preserve, not a scaffold to replace.

## Already Built

- Native SwiftUI app targeting iOS, iPadOS, macOS, and visionOS through `aibotwithfeelings.xcodeproj`.
- `RootView` app shell with onboarding, chat, character management, subscription gating, paywall, and expired-subscription states.
- Gemini-backed Ava response pipeline with `IntentAnalyzer`, `AvaBrain`, `GeminiService`, and six external-intel tools.
- StoreKit 2 subscription manager with trial, premium, restore, and access-tier logic.
- Built-in Ava personality plus premium custom character model, prompt builder, creator UI, and local character storage.
- Unit test coverage for intent routing, personality prompt rules, access tiers, and character validation.
- Cursor Cloud development notes documenting macOS/Xcode requirements and Linux harness limitations.

## Working

- The app has a coherent SwiftUI navigation foundation and launches through `ContentView` into `RootView`.
- Offline fallback responses work when no Gemini key is configured, while external modules can still enrich replies.
- StoreKit access tiers are modeled centrally in `AppState` and `SubscriptionManager`.
- Custom characters can be represented, validated, saved locally, and selected when premium access allows it.
- The Xcode folder-sync project structure can auto-include new source files under the app folder.

## Broken

- Full Xcode build, simulator launch, StoreKit configuration testing, and UI tests cannot run on the Linux Cloud Agent VM.
- `main` had only the Xcode starter template before the Ava branch was integrated into this work branch.
- Chat history and long-term emotional memory are not persisted yet.
- Gemini API keys are still client-provided, so a backend proxy remains needed before production.
- App icon image assets, App Store metadata, CI, and release automation are still missing.

## Missing

- Persistent conversations per character, including restore-on-launch behavior.
- Long-term memory summaries and user profile preferences.
- Dedicated safety UX, crisis-resource handling, and stronger moderation beyond prompt rules.
- Settings for privacy, data deletion, model/backend configuration, and notification preferences.
- Shared release process for TestFlight/App Store and platform-specific QA checklist.
- Android/Play Store implementation; this repository is Apple-platform only today.

## Needs Refactor

- Move Gemini calls behind a server proxy before production so secrets, quota, and rate limits are not controlled by the client.
- Persist chat history with a first-party Apple persistence layer such as SwiftData.
- Add retry, timeout, and user-visible degraded-mode behavior for Gemini and external tools.
- Split app settings into a dedicated screen once privacy, history, and configuration actions exist.
- Consider lowering deployment targets only after confirming the desired device support matrix.

## Next Build Priority

1. Preserve and harden the current Ava foundation.
2. Add response safety and anti-echo guardrails in the existing AI pipeline.
3. Add conversation persistence per character.
4. Add privacy/settings controls for clearing local data and explaining external AI/API usage.
5. Add App Store readiness assets: icons, screenshots, privacy policy, and metadata.
6. Add macOS-based CI once a shared scheme and runner are available.

## Testing Required

- Run `xcodebuild build` and `xcodebuild test` on macOS with Xcode 26.5+.
- Run StoreKit trial, purchase, expiration, and restore flows with `Products.storekit` attached to the scheme.
- Exercise chat in no-key offline mode, valid Gemini-key mode, and Gemini quota-error mode.
- Verify external modules for weather, web search, Wikipedia, news, quotes, and creative spark.
- Add UI tests for onboarding, paywall gating, chat send, and character selection.

## Deployment Prep

- Keep the existing bundle ID and signing team unless the owner intentionally changes Apple Developer accounts.
- Add and maintain a shared Xcode scheme for reproducible CLI builds.
- Keep generated user data, DerivedData, and secrets out of git.
- Add `PrivacyInfo.xcprivacy` and complete App Store privacy disclosures before external testing.
- Prepare app icon PNGs, App Store screenshots, support URL, privacy policy URL, and TestFlight notes.
- Treat Play Store readiness as a separate future Android project unless a cross-platform target is introduced.
