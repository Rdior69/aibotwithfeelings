# AI Bot With Feelings

A private, on-device iOS/macOS AI companion that has *feelings* — it builds an
emotional memory of your conversations, maintains a consistent personality, and
responds with empathy. Everything runs locally; nothing leaves the device.

## Status

This started as a bare SwiftUI template ("Hello, world!"). It now contains a
complete, testable companion engine plus a full multi-screen SwiftUI app built
on top of it.

## Architecture

The code is split into a UI-independent **Core** (Foundation only, fully unit
tested) and a **SwiftUI** layer on top.

```
aibotwithfeelings/
├── Core/                      # Foundation-only, no UI — unit tested
│   ├── Models/                # Emotion, ChatMessage, Personality, MemoryItem, UserProfile
│   ├── Engine/
│   │   ├── EmotionEngine.swift     # On-device sentiment + mood evolution
│   │   ├── MemoryStore.swift       # Fact/preference extraction + relevance recall
│   │   ├── SafetyGuard.swift       # Crisis detection + supportive resources
│   │   ├── ResponseGenerator.swift # Pluggable reply engine (local; LLM-ready)
│   │   └── BotBrain.swift          # Orchestrates one conversational turn
│   └── Persistence/
│       ├── PersistenceController.swift  # JSON snapshot on disk
│       └── AppState.swift               # @MainActor ObservableObject (UI bridge)
├── Features/
│   ├── Onboarding/            # Name + personality selection
│   ├── Chat/                  # Mood header, bubbles, typing indicator, input
│   ├── Memories/              # Review & delete what the bot remembers
│   └── Settings/             # Profile, personality, privacy, safety, about
├── Theme/                     # Mood-driven colours & gradients
├── ContentView.swift          # Root router (onboarding gate + tab bar)
└── aibotwithfeelingsApp.swift # App entry, injects AppState
```

### Why a separate Core?

The `Core` has **no SwiftUI/UIKit/Combine dependency**, so the entire "brain"
(emotion, memory, safety, personality, persistence) compiles and is unit-tested
headlessly via Swift Package Manager — even on Linux CI without Xcode.

## The companion's "feelings"

- **EmotionEngine** scores text against a sentiment lexicon (with negation &
  intensifier handling) into eight emotions. The bot's `MoodState` decays toward
  baseline each turn and absorbs new signals scaled by the personality's
  `sensitivity`, producing believable mood drift rather than abrupt flips.
- **MemoryStore** extracts durable facts ("my name is…"), preferences
  ("I love…/I hate…") and strong emotional moments, then recalls the most
  relevant ones (keyword overlap × importance × recency) on later turns.
- **Personality** presets (Warm Companion, Sunny Optimist, Calm Listener, Witty
  Friend) tune warmth/humor/energy/sensitivity for a consistent voice.
- **SafetyGuard** runs *before* normal replies; self-harm/crisis language yields
  a calm, supportive message with helpline resources and is never stored.

## Swapping in a real LLM

`ResponseProvider` is the single seam. The bundled `LocalResponseGenerator`
keeps the app fully offline; a future `RemoteResponseGenerator` can call an LLM
API and be injected into `BotBrain` without touching the UI or engine.

## Testing

Core logic is covered by Swift Testing suites in `aibotwithfeelingsTests/`
(EmotionEngine, MemoryStore, SafetyGuard, ResponseGenerator, BotBrain,
Persistence). In Xcode: ⌘U.

Headless run (no Xcode required) used during development:

```bash
# A throwaway SPM package that compiles Core/ + the test suites.
swift test
```

All 36 tests pass.

## App Store / Play Store readiness (next steps)

- [x] No network use → privacy-friendly; on-device only.
- [x] Crisis-safety messaging with helpline resources.
- [ ] App icon assets (currently placeholder slots in `Assets.xcassets`).
- [ ] App Privacy "Nutrition Label": declare *no data collected*.
- [ ] Add a short privacy policy URL.
- [ ] Screenshots for each device class.
- [ ] (Play Store) The Xcode project is iOS/macOS; an Android target would
      require porting the SwiftUI layer (the Core logic is portable in spirit).
