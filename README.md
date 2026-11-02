# Doomsday Clock

**Your time is your currency.**

A calm productivity clock for ADHD minds, inspired by the film *In Time*. Sleep, work and the commute are paid before you wake; Doomsday Clock shows the free time you actually own today and lets you choose what to spend it on.

## Features

- **Flip clock:** dot-matrix LED digits on split-flap tiles that flip every second and minute
- **Free time left today:** what remains after your obligations, draining as the day goes
- **Urgency-aware glass UI:** the backdrop shifts from calm indigo to amber to red as free time runs out
- **Time wallet:** obligations (sleep, job, commute...) debited from every day
- **Life bank:** your estimated remaining lifespan, ticking
- **Tasks:** up to 3 in focus, each with an optional time budget
- **Notes:** quick capture; pinned notes resurface at an interval
- **Alarms, timer, stopwatch**
- **Quarter-hour check-ins**, streaks, a daily quote
- Dark, light and black themes

## Run

```bash
flutter pub get
flutter run -d chrome          # web, hot reload
flutter build web --release    # production build in build/web
```

## Documentation

Start with [CLAUDE.md](CLAUDE.md) (rules and reading order), then [docs/README.md](docs/README.md) for the full index: PRD, system spec, system design, code map, mind map, features, history, decisions and the development lifecycle.

## Built with

Flutter, Provider, shared_preferences, google_fonts, intl, uuid.
