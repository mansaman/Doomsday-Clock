# History

Newest first. Every change gets an entry: date, what, why, files. Keep entries factual.

---

## 2026-11-02: v2 deployed; landing page live

**What:**
- App: committed v2 as `68d31e3` and pushed to `github.com/mansaman/Doomsday-Clock` (public, `main`). Deployed to Vercel project `doomsday-clock` → https://doomsday-clock-teal.vercel.app (now v2; it previously served v1 from September). Added `.vercelignore` (excludes build output and native platform folders).
- Landing: new **private** repo `github.com/mansaman/Doomsday-Clock-Landing`, new Vercel project `doomsday-clock-landing` (Git-connected, so pushes auto-deploy) → https://doomsday-clock-landing.vercel.app. "Open web app" links to the live app. Download links are still empty, so they show "Soon".
**Why:** The user asked to push the app to GitHub and Vercel, and to put the landing page in a new repo and Vercel project.
**Note:** Browsers that opened the old app may keep a cached v1 (Flutter service worker) until a hard refresh.

## 2026-11-02: Windows .exe and landing page

**What:**
- Built the Windows release: `build/windows/x64/runner/Release/doomsday_clock.exe` (it needs the `data/` folder and `flutter_windows.dll` beside it). Packaged as `dist/DoomsdayClock-windows-x64.zip` (11.5 MB). Smoke test: it launches and stays running.
- New sibling repo `../doomsday-landing` (own git repo, meant for its own GitHub + Vercel project): a static marketing site in a Nothing-style dot-matrix + glass + deep-space lane, with big type. It has a live flip clock (same glyphs as the app), an interactive time wallet, a life-in-weeks grid, app screenshots, platform downloads and a manifesto footer. Download links are placeholders in `LINKS` in its `main.js`.
**Why:** The user's multi-platform plan: a landing page plus exe, dmg, apk, the web app and an extension. They asked to build the exe and the landing page first.
**Note:** The web app and the Flutter app are the same codebase, so they already share one design. Older deployed copies just need a redeploy.
**Files:** `.gitignore` (dist/), `docs/*`, `../doomsday-landing/*`.

## 2026-11-02: Project documentation set

**What:** Added `CLAUDE.md` (agent rules and reading order), `DESIGN.md`, and `docs/` (PRD, system spec, system design, map, mind map, features, history, decisions, SDLC). Updated `README.md` to match the current app.
**Why:** The user asked for persistent docs so AI sessions stop drifting and every session starts from the same understanding.

## 2026-11-02: Dot-matrix split-flap clock on home

**What:** New `FlipClock` widget: 5x7 dot-matrix digits on split-flap tiles. Hours and minutes are large; seconds are small tiles beside the AM/PM label; weekday above, date below (DotGothic16 font). Each tile flips (old top half falls, new bottom half drops) when its digit changes. Respects reduce motion and the 24-hour system setting. It sits in a glass panel at the top of home. Free time moved below it and now reads `h:mm`.
**Why:** The user supplied a reference image of an LED dot-matrix clock and asked for flaps that change with the seconds and minutes.
**Files:** `lib/widgets/flip_clock.dart` (new), `lib/screens/home_screen.dart`.
**Not done:** the battery % from the reference image (web browsers mostly do not expose it; it would need a plugin).

## 2026-11-02: Apple-style glass redesign of the whole app

**What:**
- Removed the analog clock (`lib/widgets/analog_clock/`, already unused) and the 280px circular free-time ring with particles on home.
- New design system: `Palette` theme extension (dark, light, black), `AppText` type scale, Inter via `google_fonts`. Deleted `AppColors`.
- New shared components in `lib/widgets/glass.dart`: `GlassBackdrop`, `GlassPanel`, `GlassGroup`/`GlassRow` (iOS inset grouped lists), `RowIcon`, `GlassIconButton`, `GlassButton`, `SegmentedPicker`, `GlassScaffold`, `showGlassSheet`, `EmptyState`, `CaptureField`.
- The backdrop color carries state: calm indigo/teal while free time is plentiful, moving to amber and then red as it runs out. It is static (no loop) and eases only when urgency changes.
- Rebuilt every screen on the system: home, tasks, notes, alarms, timer/stopwatch, time wallet (allocations), settings, onboarding, splash.
- Copy rewritten to calm sentence case (no shaming, no all caps).
- Dialogs replaced with glass bottom sheets; Cupertino switches, date pickers and sliding segmented controls; Cupertino page transitions on all platforms.
- Removed `ambient_particles.dart`, `page_transitions.dart`, `life_countdown.dart`.
**Behavior fixes made along the way:**
- Quick alarm presets now actually create an alarm (before, they only showed a toast).
- Timer and stopwatch now keep running when you switch between them (IndexedStack).
- The Add task button is disabled at 3 active tasks.
- Light mode works everywhere (before, most screens used hardcoded dark colors).
- The free-time progress bar fill was zero height; fixed.
**Why:** The user asked to remove the big clock and refine the whole UI in an Apple glassmorphism style. They chose: remove both clock and ring, calm tone, dark and light, install Flutter.
**Also:** Installed Flutter 3.47.9 at `C:\Users\AmanSharma\flutter`. Wrote `PRODUCT.md`. Updated the splash widget test for the new title and to dispose timers.
**Files:** nearly all of `lib/`, `pubspec.yaml`, `test/widget_test.dart`, `PRODUCT.md`.

## Before 2026-11-02: uncommitted work found in the tree

At the start of the 2026-11-02 session these were present but uncommitted: `life_expectancy_predictor.dart` (lifestyle-based estimate in onboarding), `animated_pressable.dart`, `ambient_particles.dart`, `page_transitions.dart`, the circular free-time ring on home, streaks and daily quotes, `vercel.json` and `vercel-build.sh` (Vercel deployment). Origin: an earlier session; no log exists.

## 2026-09-02: Hourglass logo (commit `7717d30`)

Added the hourglass favicon and PWA icons, and updated web metadata.

## 2026-09-02: Initial app (commit `afa7ac0`)

"Doomsday Clock: time-as-currency productivity app for ADHD." Life bank, time wallet, analog clock with red hands, quick notes with flash reminders, 3-task limit, alarms, timer/stopwatch, dramatic dark red theme.
