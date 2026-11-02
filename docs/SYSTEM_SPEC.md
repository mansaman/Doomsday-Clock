# System specification

Exact behavior, formulas, data and storage. If code and this document disagree, the code is the truth: fix this document and log it in [HISTORY.md](HISTORY.md).

## 1. App flow

```
launch → AppState._init (load prefs, profile, allocations; pick quote; update streak)
       → RootGate
           not ready      → Splash
           not onboarded  → Onboarding (5 steps) → completeOnboarding()
           onboarded      → Home
```

## 2. Time model (`LifeCalculator`)

| Quantity | Formula |
|---|---|
| `deathDate` | DOB + `lifeExpectancyYears` |
| `remaining` | `deathDate - now` (min 0) |
| `lived` | `now - DOB` |
| `percentageLived` | `lived / totalLifespan` |
| `totalAllocatedHoursPerDay` | sum of `hoursPerDay` over **active** allocations |
| `freeTimeToday` | `(minutes in day) - allocated minutes`, clamped to ≥ 0 |
| `freeTimeElapsed` | `max(0, minutes since midnight - allocated minutes)` |
| `freeTimeRemaining` | `freeTimeToday - freeTimeElapsed` (min 0) |
| `freeTimePercentageRemaining` | `remaining / today` (0 if today is 0) |
| `isFreeTimeExhausted` | remaining is 0 and today > 0 |
| `lifeCostPercentage(m)` | `m / remaining minutes * 100` |

Model note: obligations are treated as if they all happen first, so free time does not start draining until the allocated hours have passed since midnight. Free time is minute-granular, which is why home shows `h:mm`.

## 3. Urgency

`urgencyOf(calc)` = 1 if exhausted, else `1 - freeTimePercentageRemaining`, clamped 0..1.

| Urgency | Backdrop | Free-time text | Progress bar |
|---|---|---|---|
| < 0.6 | calm → tense blend (indigo, teal, violet → amber, rose) | label | accent |
| 0.6 to 0.85 | tense → spent blend | warning | warning |
| ≥ 0.85 | toward red, magenta, plum | danger | danger, plus a "pick the one thing" status line |
| 1 (exhausted) | spent | danger | "Today's free time is spent. It refills at midnight." |

The backdrop re-reads urgency every 30 s and eases over 1.2 s (instantly under reduced motion).

## 4. Features

### Home
- Ticker every 500 ms; rebuilds only when the second changes.
- Flip clock: 12h with AM/PM unless the system uses 24h. Digits flip in 560 ms (old top half falls with easeInQuad, new bottom half lands with easeOutQuart); no flip under reduced motion.
- Quarter-hour check-in at minutes 0, 15, 30 and 45: a banner for 5 s (tap to dismiss). The message is chosen by `second % count`.
- Up next shows up to 3 active tasks; the circle toggles completion.

### Tasks
- `addTask(name, allocatedMinutes?)`. The UI blocks adding when 3 are active (AppState does not enforce it).
- Budgets: none, 15m, 30m, 1h, 2h, 4h. The row shows `Budget Xm · Y% of your life bank`.

### Notes
- Max 300 chars. Interval: off, 5, 15, 30, 60 min. Pinned notes with an interval are "armed".
- `FlashReminderOverlay` starts a periodic timer per armed note while home is mounted; a firing note shows for 6 s.

### Alarms
- Quick presets create an alarm at now + 5/15/30/60 min with the label "Back to it".
- Custom: Cupertino time picker plus an optional label.
- **Alarms do not ring yet.** No scheduler or notification exists (see known gaps).

### Timer and stopwatch
- Timer presets 5/15/25/45/60 min (default 25). Completion: heavy haptic + snackbar. The final minute turns the readout to warning.
- Stopwatch ticks every 30 ms; laps are listed newest first.

### Time wallet
- Seeded on first run: Sleep 8h (S), Job 9h (J), Commute 1.5h (C) = 18.5h.
- Slider 0.5 to 12h in 0.5 steps. Badges: S J C R E M W H G P.
- More than 24h shows the over-budget state in danger color.

### Settings
- Theme: 0 dark, 1 light, 2 black.
- Life expectancy slider 50 to 100.
- Reset: Cupertino confirm, then `LocalStorage.clearProfile()` and pop to root (other data stays).

### Onboarding estimate (`LifeExpectancyPredictor`)
Base 78; male −4, female +4; smoker −10; exercise +5; healthy diet +3; manages stress +2; age > 40 +1; age > 60 +2; clamped to 50..105.

### Streak
On launch: same day → no change; last active yesterday → +1; otherwise → 1. Longest = max.

## 5. Data model

| Model | Fields |
|---|---|
| `UserProfile` | dateOfBirth, lifeExpectancyYears, isOnboarded |
| `TimeAllocation` | id, name, hoursPerDay, icon (letter), isActive |
| `WorkTask` | id, name, allocatedMinutes?, isCompleted, isActive, createdAt |
| `QuickNote` | id, content, flashIntervalMinutes?, isPinned, createdAt |
| `AppAlarm` | id, hour, minute, message, isActive, repeatDaily |

## 6. Persistence (`SharedPreferences`; localStorage on web)

| Key | Format | Written by |
|---|---|---|
| `user_profile` | `ISO-DOB|years|onboarded` | `LocalStorage.saveProfile` |
| `time_allocations` | records joined by `~~`, fields by `|`: `id|name|hours|icon|active` | `AppState._persistAllocations` |
| `theme_mode` | int | `AppState._savePreferences` |
| `current_streak`, `longest_streak` | int | same |
| `last_active_date` | `y-m-d` (not zero padded) | same |

**Not persisted:** tasks, notes, alarms (lost on reload).

## 7. Copy rules

Sentence case. No exclamation marks, all caps, shaming, or em dashes. Short and direct. Urgency through facts ("Under 40m left"), never insults.
