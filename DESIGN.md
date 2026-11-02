# Design system

Apple-style glass, calm by default, urgent only when time is short. Source of truth: [lib/theme/palette.dart](lib/theme/palette.dart), [lib/theme/app_theme.dart](lib/theme/app_theme.dart), [lib/widgets/glass.dart](lib/widgets/glass.dart).

## Visual theme

Frosted glass panels float over a soft, static color field. The field's hue is the day's state: indigo and teal while free time is plentiful, amber and rose as it thins, red and plum when it is spent. Everything else stays neutral, so color always means something.

## Color tokens (`context.palette`)

| Token | Dark | Light | Use |
|---|---|---|---|
| canvas | `#0C0C14` | `#F1F0F7` | Base behind the backdrop (black mode: `#000000`) |
| glassFill | white-tinted 55% `#1C1C28` | 65% white | Panels |
| glassFillStrong | 85% | 90% | Sheets, banners |
| glassStroke | white 12% | ink 6% | 1px panel border |
| label / secondary / tertiary | `#F4F4FA` / 70% / 45% | `#15151F` / 60% / 40% | Text hierarchy |
| accent | `#8E8CF7` | `#5552D9` | Primary actions, selection, calm progress |
| success | `#4CD787` | `#1F9D55` | Done, healthy |
| warning | `#FFB340` | `#C77800` | Obligations, mid urgency, reminders |
| danger | `#FF6961` | `#D7372E` | High urgency, destructive |

Strategy: restrained. Accent only on actions and state; red only at urgency ≥ 0.85 or for destructive actions.

## Typography

Inter (via `google_fonts`), using Apple's text style names (`AppText`):

| Style | Size / weight |
|---|---|
| largeTitle | 34 / 700, −0.8 tracking |
| title2 | 22 / 700 |
| title3 | 20 / 600 |
| headline | 17 / 600 |
| body | 17 / 400 |
| callout | 16 / 400 |
| subhead | 15 / 400 |
| footnote | 13 / 400 |
| caption | 12 / 500 |

Numerals: free time is 72 / w300, timers 88 / w200, always with tabular figures. Clock labels (weekday, date, AM/PM) use **DotGothic16** to match the LED clock; nowhere else.

## Components

| Component | Spec |
|---|---|
| `GlassPanel` | Radius 22 (28 for hero panels), blur σ28, 1px stroke, top sheen over the first 45% |
| `GlassGroup` + `GlassRow` | iOS inset grouped list; rows at least 52 tall, 16px inset hairline separators, pressed state = fieldFill |
| `RowIcon` | 30px rounded square, 18% tint fill, glyph in the tint |
| `GlassIconButton` | 44px glass circle |
| `GlassButton` | Height 50 (compact 38), capsule. Styles: filled, tinted (20%/12% fill), plain. Disabled = 40% opacity |
| `SegmentedPicker` | `CupertinoSlidingSegmentedControl` on fieldFill |
| `GlassScaffold` | Backdrop + back button + large title + list body, max width 640 |
| `showGlassSheet` | Bottom sheet with top radius 28, grabber, strong glass |
| `FlipClock` / `FlipTile` | 5x7 dot matrix, dot = 80% of the cell, radius 18%; unlit dots at 6 to 7% label; hinge line at mid-height; tile radius 0.9 cell |
| Switches, pickers | Cupertino (`CupertinoSwitch` with accent track, `CupertinoDatePicker`) |

## Layout

16px page gutters, content max width 640. Section rhythm: 28 to 32px between groups, 16px within. Prefer grouped lists over card grids; the home dock is one bar, not four cards.

## Motion

- Press: scale 0.97 + dim, 120ms in / 220ms out, easeOutQuart.
- Transitions: Cupertino page route; sheets slide up.
- Flip: 560ms, easeInQuad (fall) then easeOutQuart (land).
- Backdrop: eases 1.2s on urgency change; never loops.
- Reduced motion: flips and backdrop easing switch off.

## Copy

Sentence case, short, factual. No all caps, no shaming, no exclamation marks, no em dashes.
