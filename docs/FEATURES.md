# Features

Status: ✅ done · 🟡 partial · ⛔ not started. Requirement IDs refer to [PRD.md](PRD.md).

| Feature | Req | Status | Notes |
|---|---|---|---|
| Onboarding with lifespan estimate | R1 | ✅ | 5 steps; editable later in Settings |
| Dot-matrix split-flap clock | R2 | ✅ | Hours, minutes and seconds flip; 12/24h follows the system |
| Free time left + progress | R2, R3 | ✅ | `h:mm`, minute-granular |
| Urgency-colored backdrop | R2 | ✅ | Calm → amber → red |
| Time wallet | R4 | ✅ | Seeded with Sleep, Job, Commute |
| Life bank | R5 | ✅ | In "The long view" on home |
| Tasks (max 3) | R6 | 🟡 | Limit enforced in the UI only; not persisted |
| Notes with resurfacing | R7 | 🟡 | Works while home is open; not persisted |
| Alarms | R8 | 🟡 | Created, listed, toggled; **never ring**; not persisted |
| Timer and stopwatch | R9 | ✅ | State is lost when leaving the screen |
| Quarter-hour check-in | R10 | ✅ | Only while the app is open |
| Streaks + daily quote | R11 | ✅ | |
| Dark / light / black | R12 | ✅ | |
| Reset everything | R13 | 🟡 | Clears the profile only; allocations, theme and streaks remain |
| Battery % on clock | n/a | ⛔ | In the user's reference image; needs a plugin, and web support is limited |

## Platforms

| Target | Status | How | Blocker |
|---|---|---|---|
| Web app | ✅ live | `flutter build web --release` → `build/web`, Vercel → https://doomsday-clock-teal.vercel.app | |
| Windows .exe | ✅ released | `flutter build windows --release`, zipped to `dist/`, attached to GitHub Release `v2.0.0`; linked from the landing page | Unsigned: SmartScreen shows "unknown publisher" |
| macOS .dmg | ⛔ | `flutter build macos` + `create-dmg` | Needs a Mac or a GitHub Actions macOS runner; notarization needs an Apple Developer ID ($99/yr) |
| Android .apk | ⛔ | `flutter build apk --release` | Android SDK not installed on this PC; needs a release keystore |
| Browser extension | ⛔ | Separate small project (not the Flutter app) | Scope undecided |
| Landing page | ✅ live | `../doomsday-landing` (static), https://doomsday-clock-landing.vercel.app | macOS, Android and extension links in `LINKS` still empty ("Soon") |

## Known gaps

Log issues here instead of fixing them unasked.

1. Tasks, notes and alarms live in memory only and disappear on reload.
2. Alarms have no scheduler and no system notification, so they never fire.
3. `AppState.addTask` does not enforce the 3-task limit (the UI does).
4. Reset leaves allocations, theme and streaks in storage.
5. The free-time model assumes obligations happen first in the day, so free time does not drain until the allocated hours have passed since midnight.
6. Profile and allocation storage uses `|`-delimited strings; a `|` in an obligation name would corrupt it.
7. Inter and DotGothic16 load from Google Fonts at runtime; offline first launch falls back to the default font.
8. Leftover v1 copy in `AppState._quotes` may still be harsh in tone.

## Roadmap

1. Persist tasks, notes and alarms (JSON in SharedPreferences).
2. Real alarm and reminder notifications (`flutter_local_notifications`; web Notifications API).
3. Bundle fonts as assets for offline use.
4. A truer free-time model: obligations placed on the clock (for example, sleep 23:00 to 07:00).
5. Optional cloud sync.
