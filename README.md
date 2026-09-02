# ⚠️ Doomsday Clock

**Your time is your currency.**

A productivity clock built for ADHD minds. Inspired by the movie *In Time*: every day, you pay for life with your time. Sleep, job, commute — that money is already gone before you wake. This app shows you exactly how much **free time you actually own today**, and watches every second of it drain away.

> 8h of sleep. 9h at work. 2h commuting. That money is already gone before you wake.
> We calculate exactly how much FREE TIME you own today. And we watch every second of it drain away.

## Features

- 🕐 **Life Bank** — your remaining lifespan (DOB + life expectancy) ticking down in real time
- 💳 **Time Wallet** — daily obligations (sleep, job, commute, gym...) debit your balance. See your real free time left today
- ⏰ **Analogue clock** — dramatic custom-painted clock with glowing red hands
- 📝 **Quick Notes** — zero-friction brain dump. Pin a note with a flash interval to keep it on your face
- ⚡ **Flash Reminders** — pinned notes flash on screen at set intervals (5m / 15m / 30m / 60m)
- ✅ **Tasks** — max 3 active tasks. Each shows how much of your life bank it drains
- 🔔 **Alarms** — quick presets + custom alarms with moody messages
- ⏱ **Timer & Stopwatch** — countdown with urgency effects, stopwatch with laps
- 💀 **The "die" moment** — when today's free time hits zero, the day is done

## Built With

- Flutter (macOS / Windows / iOS / Android / Web)
- Provider (state management)
- shared_preferences (local persistence)

## Getting Started

```bash
flutter pub get
flutter run -d chrome      # web
flutter run -d windows     # Windows desktop (requires Developer Mode enabled)
```

## Roadmap

- [ ] Persist notes / alarms / tasks across restarts
- [ ] Firebase cloud sync (offline-first)
- [ ] System notifications for alarms
- [ ] Sounds, screen-shake, app icon polish
- [ ] "Exact death date" mode for the truly enlightened