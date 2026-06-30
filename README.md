# AIBotWithFeelings

A SwiftUI companion app foundation that now includes:

- Onboarding for name, tone, memory, and check-in preferences.
- Chat flow with message bubbles, compose/send UI, and async bot replies.
- Emotional state tracking via a deterministic emotion engine.
- In-memory key moment storage and local profile persistence.
- Settings sheet for profile updates.

## Architecture

- `aibotwithfeelings/Models`: chat, emotion, profile, memory models.
- `aibotwithfeelings/Services`: AI service protocol + mock implementation, memory store, local profile store.
- `aibotwithfeelings/ViewModels`: app state router and chat state manager.
- `aibotwithfeelings/Views`: onboarding, chat, and settings screens.

## Next Steps

1. Swap `MockAICompanionService` for a production AI backend implementation.
2. Add safety policy checks for crisis and over-attachment boundaries.
3. Persist full conversation history and memory controls.
4. Run and expand UI/unit tests on macOS with Xcode.
