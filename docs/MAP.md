# Code map

Where everything lives. Paths are relative to the repo root.

## Entry and routing

| File | Owns |
|---|---|
| [lib/main.dart](../lib/main.dart) | `main()`, `DoomsdayClockApp` (Provider + theme switch on `AppState.themeMode`: 0 dark, 1 light, 2 black), `RootGate` (splash → onboarding → home), `_CinematicSplash` |

## Screens (`lib/screens/`)

| File | Screen | Reached from |
|---|---|---|
| [home_screen.dart](../lib/screens/home_screen.dart) | Home: top bar + streak, `FlipClock`, free-time hero + progress, Up next (top 3 tasks), dock (Notes, Timer, Alarms, Wallet), The long view (life bank, time wallet), armed reminders, daily quote, quarter-hour check-in banner | `RootGate` |
| [onboarding_screen.dart](../lib/screens/onboarding_screen.dart) | 5 steps: intro, date of birth, biological sex, habits, predicted lifespan | `RootGate` when not onboarded |
| [tasks_screen.dart](../lib/screens/tasks_screen.dart) | Add task with time budget, In focus (max 3), Done | Home: Up next |
| [notes_screen.dart](../lib/screens/notes_screen.dart) | Capture a note with a resurface interval, Pinned, All notes | Home dock |
| [alarms_screen.dart](../lib/screens/alarms_screen.dart) | Quick alarms from now, custom alarm sheet, alarm list | Home dock |
| [timer_stopwatch_screen.dart](../lib/screens/timer_stopwatch_screen.dart) | Segmented Timer / Stopwatch (IndexedStack keeps both alive) | Home dock |
| [allocations_screen.dart](../lib/screens/allocations_screen.dart) | Time wallet: committed vs yours, 24h split bar, obligations list, add/edit sheet | Home dock, The long view |
| [settings_screen.dart](../lib/screens/settings_screen.dart) | Appearance, lifespan (birthday and expectancy sheets), life so far, today, streaks, reset | Home gear |

## Widgets (`lib/widgets/`)

| File | Contents |
|---|---|
| [glass.dart](../lib/widgets/glass.dart) | The design system's components: `urgencyOf`, `GlassBackdrop`, `GlassPanel`, `GlassGroup`, `GlassRow`, `RowIcon`, `GlassIconButton`, `GlassButton` (+ `GlassButtonStyle`), `SegmentedPicker`, `GlassScaffold`, `showGlassSheet`, `EmptyState`, `CaptureField`, `formatHm`, `formatHours` |
| [flip_clock.dart](../lib/widgets/flip_clock.dart) | `FlipClock` (dot-matrix LED clock), `FlipTile` (split-flap digit), 5x7 glyph table, `_DotGlyphPainter` |
| [flash_reminder_overlay.dart](../lib/widgets/flash_reminder_overlay.dart) | Armed-reminders row on home; becomes a highlighted card when a pinned note's interval fires |
| [flash_interval_picker.dart](../lib/widgets/flash_interval_picker.dart) | Segmented Off / 5m / 15m / 30m / 1h (0 stands in for off) |
| [animated_pressable.dart](../lib/widgets/animated_pressable.dart) | Press feedback: scale 0.97 + dim + selection haptic |

## Theme (`lib/theme/`)

| File | Contents |
|---|---|
| [palette.dart](../lib/theme/palette.dart) | `Palette` ThemeExtension (dark, light, black tokens), `backdropFor(urgency)`, `urgencyTint`, `context.palette`, `AppText` type scale |
| [app_theme.dart](../lib/theme/app_theme.dart) | Builds `ThemeData` from a `Palette`: Inter text theme, inputs, slider, snackbar, Cupertino transitions |

## Services (`lib/services/`)

| File | Contents |
|---|---|
| [app_state.dart](../lib/services/app_state.dart) | `ChangeNotifier` holding profile, allocations, notes, alarms, tasks, theme, streaks, daily quote. All mutations go here. |
| [life_calculator.dart](../lib/services/life_calculator.dart) | Pure math: death date, remaining, lived %, free time today/remaining/%, life cost of minutes |
| [life_expectancy_predictor.dart](../lib/services/life_expectancy_predictor.dart) | Lifestyle-based lifespan estimate used in onboarding |
| [local_storage_service.dart](../lib/services/local_storage_service.dart) | Profile load/save/clear in `SharedPreferences` |

## Models (`lib/models/`)

`user_profile.dart` (DOB, life expectancy, onboarded), `time_allocation.dart` (obligation: name, hours/day, badge letter, active), `task.dart` (`WorkTask`), `note.dart` (`QuickNote`), `alarm.dart` (`AppAlarm`).

## Other

| Path | Purpose |
|---|---|
| [test/widget_test.dart](../test/widget_test.dart) | LifeCalculator unit test; splash smoke test |
| [web/](../web/) | index.html, manifest, favicon, PWA icons |
| [vercel.json](../vercel.json), [vercel-build.sh](../vercel-build.sh) | Vercel deployment (installs Flutter, builds web, serves `build/web`) |
| `PRODUCT.md`, `DESIGN.md`, `CLAUDE.md`, `docs/` | Documentation |
| `.playwright-mcp/` | Browser screenshots from verification sessions (scratch; safe to delete; gitignored) |
| `dist/` | Packaged release artifacts, e.g. `DoomsdayClock-windows-x64.zip` (gitignored) |
| `../doomsday-landing/` | **Separate repo:** the marketing landing page (static). See its README. |
