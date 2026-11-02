# Doomsday Clock: agent guide

Read this before touching code. It exists so every AI session stays on the same track instead of re-deriving (or reinventing) the system.

## What this is

A Flutter app (web first, also iOS/Android/desktop) for people with ADHD that treats time as currency: obligations are debited from the day, and the app shows the **free time you actually own today**, plus your remaining lifespan ("life bank"), up to 3 focus tasks, notes that resurface, alarms, a timer and a stopwatch.

## Reading order

1. [docs/README.md](docs/README.md): index of all docs
2. [PRODUCT.md](PRODUCT.md): who it is for, tone, principles (strategic)
3. [DESIGN.md](DESIGN.md): visual system, tokens, components (visual)
4. [docs/MAP.md](docs/MAP.md): where every piece of code lives
5. [docs/HISTORY.md](docs/HISTORY.md): what has been done, newest first
6. [docs/FEATURES.md](docs/FEATURES.md): feature inventory with status and known gaps

Go deeper only when needed: [PRD](docs/PRD.md), [System spec](docs/SYSTEM_SPEC.md), [System design](docs/SYSTEM_DESIGN.md), [Decisions](docs/DECISIONS.md), [SDLC](docs/SDLC.md), [Mind map](docs/MINDMAP.md).

## Hard rules

- **Use the design system.** Colors come from `context.palette` ([lib/theme/palette.dart](lib/theme/palette.dart)), text from `AppText`, surfaces and controls from [lib/widgets/glass.dart](lib/widgets/glass.dart). Never hardcode hex colors in screens. `AppColors` was deleted on purpose; do not recreate it.
- **No analog clock, no big progress ring.** Removed at the user's request (2026-11-02). The home centerpiece is the dot-matrix split-flap `FlipClock` ([lib/widgets/flip_clock.dart](lib/widgets/flip_clock.dart)).
- **Tone is calm, urgent only when needed.** Sentence case, no shouting, no shaming copy, no em dashes. Red appears only when free time is actually low.
- **Motion conveys state only.** No looping ambient animation. Honor `MediaQuery.disableAnimations`.
- **Bottom sheets, not dialogs** (`showGlassSheet`). The one exception is the destructive reset confirmation (`CupertinoAlertDialog`).
- **State goes through `AppState`** ([lib/services/app_state.dart](lib/services/app_state.dart)) via Provider. Screens do not talk to `SharedPreferences` directly.
- Scope discipline: do what was asked. Log anything else you notice under "Known gaps" in [docs/FEATURES.md](docs/FEATURES.md) instead of fixing it unasked.

## After every change

1. `flutter analyze` must report no issues; `flutter test` must pass.
2. Add an entry to the top of [docs/HISTORY.md](docs/HISTORY.md) (date, what, why, files).
3. Update [docs/MAP.md](docs/MAP.md) if files were added, moved or deleted, and [docs/FEATURES.md](docs/FEATURES.md) if a feature's status changed.
4. Record any non-obvious choice in [docs/DECISIONS.md](docs/DECISIONS.md).

## Commands

Flutter is installed at `C:\Users\AmanSharma\flutter` (not on PATH by default).

```bash
export PATH="$PATH:/c/Users/AmanSharma/flutter/bin"   # Git Bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome                                   # dev with hot reload
flutter build web --release                             # output: build/web
python -m http.server 8080 --directory build/web        # serve a build at http://localhost:8080
```

On Windows, stop any server that is serving `build/web` **before** rebuilding. A server holding files open caused a partial build (missing `FontManifest.json`, broken icons).
