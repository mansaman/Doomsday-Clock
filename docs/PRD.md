# Product requirements: Doomsday Clock

Strategic context (users, tone, principles) lives in [../PRODUCT.md](../PRODUCT.md). This document covers the problem, goals, scope and requirements.

## Problem

People with ADHD experience time blindness: hours vanish without being noticed, and a day "feels" longer than it is. Calendars and to-do apps assume the user already perceives time accurately. Nothing shows plainly how much of today is actually theirs once sleep, work and commuting are paid for.

## Vision

A calm, glanceable clock that makes time visible as a finite currency, inspired by the film *In Time*. Open it for three seconds, know how much free time is left, and act.

## Goals

1. **Glanceability.** Free time left today is readable within one second of opening the app.
2. **Honest accounting.** Free time reflects the user's real obligations (time wallet).
3. **Low-friction action.** A task, note, timer or alarm is at most one tap from home.
4. **Sustained attention without shame.** Gentle quarter-hour check-ins and resurfacing notes; no guilt-tripping copy.

## Non-goals (for now)

- Calendar integration or scheduling.
- Accounts, cloud sync, multi-device.
- Analytics or social features.
- Medical accuracy for lifespan (the estimate is motivational, not clinical).

## Users

See [../PRODUCT.md](../PRODUCT.md#users). Primary: adults with ADHD on a phone or a desktop browser, opening the app many times a day for a few seconds each.

## Requirements

Priority: P0 = must have, P1 = should have, P2 = later. Status is tracked in [FEATURES.md](FEATURES.md).

### Core

| ID | Requirement | Priority |
|---|---|---|
| R1 | Onboarding collects date of birth and estimates lifespan from sex and habits; the estimate is editable | P0 |
| R2 | Home shows the current time (dot-matrix split-flap clock) and free time left today with a progress bar | P0 |
| R3 | Free time = 24h minus active obligations, drained as the day passes | P0 |
| R4 | Time wallet: add, edit, toggle and delete obligations (name, hours/day, badge) | P0 |
| R5 | Life bank: remaining lifespan shown as y/m/d plus a ticking h:m:s | P1 |
| R6 | Tasks: max 3 active, optional time budget showing its share of the life bank | P0 |
| R7 | Notes: quick capture; pin with a resurface interval (5/15/30/60 min) | P0 |
| R8 | Alarms: quick presets from now and custom times, toggle and delete | P1 |
| R9 | Timer (presets 5 to 60 min) and stopwatch with laps | P1 |
| R10 | Quarter-hour check-in banner on home | P1 |
| R11 | Streaks (daily open) and a daily quote | P2 |
| R12 | Appearance: dark, light, black | P1 |
| R13 | Reset everything | P1 |

### Non-functional

| ID | Requirement |
|---|---|
| N1 | WCAG 2.2 AA contrast, including text on glass |
| N2 | Honor reduced motion: no flips, no eased backdrop transitions |
| N3 | Tap targets of 44pt minimum |
| N4 | Works offline; data stays on the device |
| N5 | Web build loads and is usable on a 360px-wide phone and on desktop (content max width 640px) |
| N6 | `flutter analyze` clean; tests pass |

## Success metrics (qualitative until analytics exist)

- The user can say how much free time is left after one glance.
- Daily return (streak) grows over a week of use.
- At least one task completed or note captured per day of use.

## Release scope

- **v1 (Sept 2026):** core features, dramatic red theme.
- **v2 (Nov 2026, current):** glass redesign, flip clock, calm tone, light mode. See [HISTORY.md](HISTORY.md).
- **Next:** see the roadmap in [FEATURES.md](FEATURES.md#roadmap).
