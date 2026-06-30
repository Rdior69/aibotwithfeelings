# AIBotWithFeelings

An emotionally aware AI companion for iOS, built with SwiftUI and Apple's Foundation Models framework.

## Features

- **Emotionally Reactive AI** — The bot has 8 distinct emotional states (Calm, Happy, Curious, Excited, Thoughtful, Empathetic, Surprised, Melancholy) that shift based on your conversation
- **On-Device AI** — Powered by Apple Intelligence (Foundation Models framework) — no data leaves your device
- **Animated Avatar** — The bot's avatar glows and animates to reflect its current emotional state
- **Chat Persistence** — Conversations are saved via SwiftData
- **Beautiful Chat UI** — Custom message bubbles with spring animations, typing indicator, and smooth transitions
- **Onboarding Flow** — Multi-page welcome experience with bot name customization
- **Settings** — Dark/light/system mode, haptics, emotion indicator toggle, bot name

## Architecture

```
Views/            — SwiftUI views (ChatView, MessageBubbleView, BotAvatarView, OnboardingView, SettingsView)
ViewModels/       — @Observable view models (ChatViewModel)
Models/           — Data types (Message, Emotion, BotPersonality, AppSettings)
Services/         — AI service abstraction (AIServiceProtocol, AppleIntelligenceService, MockAIService, EmotionEngine)
Utilities/        — Helpers (ColorTheme, HapticManager)
```

## Requirements

- Xcode 26.5+
- iOS 26.0+ / macOS 26.0+ / visionOS 26.0+
- Apple Intelligence enabled on device (for on-device AI; falls back to demo mode otherwise)

## AI Modes

| Mode | Description |
|------|-------------|
| Apple Intelligence | On-device Foundation Models — private, no API key needed |
| Demo Mode | Pre-written contextual responses for testing/devices without Apple Intelligence |

## Emotion States

| Emotion | Trigger Keywords | Bot Tone |
|---------|-----------------|----------|
| 😌 Calm | (default) | Steady, reassuring |
| 😊 Happy | "hi", "thanks", "great" | Warm, friendly |
| 🤔 Curious | "why", "how does", "explain" | Inquisitive |
| 🌟 Excited | "amazing", "love", "fantastic" | Enthusiastic |
| 💭 Thoughtful | "meaning", "life", "believe" | Deep, philosophical |
| 💙 Empathetic | "sad", "anxious", "hurt" | Compassionate |
| 😮 Surprised | "no way", "seriously", "what" | Astonished |
| 🌧️ Melancholy | "miss", "remember when", "regret" | Gentle, reflective |

## Safety

- No medical, legal, or financial advice
- Clear AI identity disclosure
- Apple Intelligence built-in guardrails
- Age-appropriate content
