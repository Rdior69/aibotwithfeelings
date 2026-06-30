# AIBotWithFeelings

A SwiftUI companion app foundation that now includes:

- Onboarding for name, tone, memory, and check-in preferences.
- Chat flow with message bubbles, compose/send UI, and async bot replies.
- Emotional state tracking via a deterministic emotion engine.
- In-memory key moment storage and local profile persistence.
- Settings sheet for profile updates.

## Architecture

- `aibotwithfeelings/Models`: chat, emotion, profile, memory models.
- `aibotwithfeelings/Services`: backend framework — AI provider config, HTTP + fallback AI services, conversation/memory persistence, safety filtering, and `CompanionBackend` factory.
- `aibotwithfeelings/ViewModels`: app state router and chat state manager.
- `aibotwithfeelings/Views`: onboarding, chat, and settings screens.

### Backend framework

The `Services` layer is the app's backend. `CompanionBackend.make()` wires:

- **AI**: `HTTPAICompanionService` when `COMPANION_AI_API_KEY` is set (OpenAI-compatible API), otherwise `MockAICompanionService` via `FallbackAICompanionService`.
- **Memory**: `PersistentCompanionMemoryStore` (UserDefaults, max 30 items).
- **Conversation**: `LocalConversationStore` (UserDefaults, max 200 messages).
- **Safety**: crisis, harassment, and over-attachment policies via `SafetyFilter`.

Set environment variables to enable a live AI provider:

- `COMPANION_AI_API_KEY` — API key (required for live AI)
- `COMPANION_AI_BASE_URL` — optional, defaults to `https://api.openai.com/v1`
- `COMPANION_AI_MODEL` — optional, defaults to `gpt-4o-mini`

## Next Steps

1. Add UI for memory and conversation controls in Settings.
2. Implement daily check-in scheduling from profile preferences.
3. Run and expand UI/unit tests on macOS with Xcode.
