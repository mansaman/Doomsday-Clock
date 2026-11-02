# Decisions (ADR log)

Short records of non-obvious choices. Newest first. Do not reverse one without the user's say-so; add a new entry that supersedes it.

## D9 · 2026-11-02 · Release files go to GitHub Releases, not the landing repo
Binaries (zip, dmg, apk) would bloat a static site repo. The landing page links to `releases/latest/download/...` URLs instead.

## D8 · 2026-11-02 · Landing page is a separate static repo
**Context:** The user wants the landing page in a different GitHub repo and Vercel project.
**Decision:** `../doomsday-landing`: plain HTML, CSS and JS with no build step, so it is instant to deploy and has no framework to maintain. It shares the app's design language (flip clock glyphs, glass, urgency hues) but uses its own brand fonts (Doto, Funnel Display, Funnel Sans) because marketing pages need more voice than app UI.

## D7 · 2026-11-02 · Free time shows h:mm, not seconds
`LifeCalculator` is minute-granular, so the seconds were always `:00`. Seconds now live in the flip clock instead.

## D6 · 2026-11-02 · Dot-matrix split-flap clock as the home centerpiece
**Context:** The user provided a reference image of an LED dot-matrix clock and asked for flaps that change with the seconds and minutes.
**Decision:** A custom painter with 5x7 glyphs on opaque split-flap tiles, inside a glass panel; free time sits right below it.
**Consequence:** This partly reverses D1's "no big clock". The analog clock and the ring stay removed; this digital clock is what the user asked for.

## D5 · 2026-11-02 · One shared page shell (`GlassScaffold`)
Every secondary screen uses the same back button, large title and scroll body. This keeps the vocabulary consistent and avoids per-screen `AppBar` styling.

## D4 · 2026-11-02 · Bottom sheets instead of dialogs
Add/edit flows use `showGlassSheet`. Only the destructive reset uses a `CupertinoAlertDialog`.

## D3 · 2026-11-02 · Backdrop hue encodes urgency; no looping motion
Glass needs something behind it to look like glass. Rather than decorative blobs, the backdrop's color is the time signal. It is static (re-read every 30 s) for calm and performance.

## D2 · 2026-11-02 · Palette ThemeExtension replaces AppColors
`AppColors` was a set of hardcoded dark constants, which broke light mode. Tokens now come from `context.palette`, with dark, light and black variants.

## D1 · 2026-11-02 · Calm Apple-style glass, urgent only when needed
**Context:** v1 was blood red, all caps and shaming. The user asked for an Apple glassmorphism look and chose "calm, urgent only when needed", dark and light modes, and removal of the analog clock and the ring.
**Decision:** Restrained palette with an indigo accent; red only at high urgency; sentence-case copy; Inter.
