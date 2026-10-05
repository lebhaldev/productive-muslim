# 03 — Design system

Source: design export `design/2026-10-05-Nurday.dc.html`, which uses the "Organic" design system (terracotta `accent`, sage `accent-2`, warm `neutral`). The export references the DS stylesheet but does not include it, so hex values are sampled from the screenshot and the rest are interpolated [OQ-9].

The design replaced the brief's deep green + gold with sage + terracotta. No gold in v1.

## Colour tokens (light)

| Token (DS name) | Hex | Used for |
|---|---|---|
| `bg` | `#F5EAD8` (sampled) | screen background |
| `surface` | `#EBDDC5` (sampled) | habit rows, cards, nav bar, More rows |
| `neutral-100` | `#FBF5EC` | Arabic box, journal textarea, switch knob |
| `neutral-200` | `#EFE5D6` | progress track |
| `neutral-300` | `#DCD3C4` (sampled) | empty mood bar |
| `neutral-400` | `#C0B6A5` (sampled) | mood okay |
| `neutral-500` | `#9E9483` | switch off |
| `neutral-600` | `#7D7465` | empty habit ring |
| `neutral-700` | `#6B6255` | meta text |
| `neutral-800` | `#4A433A` | secondary text |
| `text` / `neutral-900` | `#201E1D` (sampled) | text |
| `accent-200` | `#FFE1D0` (sampled) | journal shortcut |
| `accent-400` | `#F6A06B` (sampled) | mood low |
| `accent-700` | `#8C491A` (sampled) | mood rough, kickers, streak labels, links |
| `accent-900` | `#5A2A0C` | text on accent-200 |
| `accent-2-200` | `#DDE6CC` | weather chip, privacy card, selected calendar day |
| `accent-2-300` | `#CCDBB2` (sampled) | active tab pill, selected unit |
| `accent-2-400` | `#AEBF92` (sampled) | mood good |
| `accent-2-600` | `#728157` (sampled) | mood bright, done check, week ring, today border, progress fill, switch on |
| `accent-2-900` | `#2F3A22` | text on sage |
| `divider` | `#D9CCB6` | input borders |

Moods: rough=`accent-700`, low=`accent-400`, okay=`neutral-400`, good=`accent-2-400`, bright=`accent-2-600`.

Dark theme: not designed [OQ-10]. Everything goes through tokens.

## Type
- Heading font (`--font-heading`): soft heavy serif. Default: **Fraunces** (SemiBold/Bold) until the DS font is confirmed [OQ-9].
- Body: system sans (Roboto) at 15px base.
- Arabic: **Amiri Quran**, 22px, line-height 1.9, RTL.
- Sizes: screen title 28, section 19, card body 15, meta 12–13, small 11.

## Radii and spacing
- `radius-md` 12, `radius-lg` 20, pills 999. Calendar cell 16.
- Screen padding 20 horizontal; section gap 18; card gap 8–10.
- Min touch target 48 (nav, mood, switch), inputs 44.

## Components
Card (surface, radius-lg, padding 16), kicker (uppercase small, letter-spaced), tag (`tag-accent`, `tag-accent-2`), ghost/primary/secondary/icon buttons, segmented control, switch, pill habit row, mood picker, 7-day ring row, calendar cell, stat card, bar chart, progress bar, bottom nav with pill + label.
