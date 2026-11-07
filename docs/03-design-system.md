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

## Colour tokens (dark)

From the design export of 26 Oct 2026 (`.dark`, marked provisional there) [OQ-10]. `onAccent` and the mood colours are ours.

| Token | Hex | Note |
|---|---|---|
| `bg` | `#1D1B18` | |
| `surface` | `#2A2723` | |
| `neutral-100` | `#25221E` | Arabic box, inputs |
| `neutral-200` | `#322E29` | progress track |
| `neutral-300` | `#3D3832` | empty mood bar |
| `neutral-400` | `#5A534A` | |
| `neutral-500` | `#776F63` | |
| `neutral-600` | `#8F8678` | empty ring |
| `neutral-700` | `#B3A998` | meta text |
| `neutral-800` | `#D4CAB9` | secondary text, Arabic |
| `text` | `#F1E8DA` | |
| `divider` | `#3D3832` | |
| `accent-200` | `#3D2A1D` | journal shortcut |
| `accent-400` | `#C9814F` | mood low |
| `accent-700` | `#E7A375` | kickers, links, buttons (dark text on it) |
| `accent-900` | `#FFE1D0` | text on accent-200 |
| `accent-2-200` | `#2F3826` | weather chip, privacy card |
| `accent-2-300` | `#3C4831` | active tab pill |
| `accent-2-400` | `#6F8257` | mood good |
| `accent-2-600` | `#A3B788` | check, today border |
| `accent-2-900` | `#DFE9CF` | text on sage |

Dark moods: rough `#D9774A`, low `#F6A06B`, okay `#8A8172`, good `#6F8257`, bright `#A3B788`.

## Colour themes [OQ-21]
Nine featured themes come first, from the owner's palettes of 7 Nov 2026 (darkest to accent): Amethyst `0E0B1D 2A1E4D 5A3B8C 8B7CC7 C9C2E3 3A3A52`, Mocha `1A120E 3A2418 6B4A2E A88462 D5C4AE 4A4A46`, Pine `0F1F17 1E3A2E 3E5A3F 6B7F67 C7CBB8 3D4337`, Harbor `0B132B 1C2541 3A506B 5BC0DE F4D6B0 D97706`, Oasis `0B0F0D 1F2A1F 3E5A3F 8CA98C D9C7A3 B08D57`, Ember `0A0F14 0F3D3E 2E6F73 7FB3B8 EADCC8 C6601F`, Berry `1A0F2E 3B1B4F 7A2E6F D6598F F4D7D4 FF6B6B`, Twilight `1A1A1F 2D2B55 6A5ACD A678B9 F0D9B5 F4A62A`, Neon `121212 1F2937 334155 64748B F1F5F9 EC4899`. The third colour is the main one; the accent is the sixth (the fourth for Amethyst, Mocha and Pine, whose sixth is grey). Light and dark sets are built from them and nudged until they pass WCAG AA. **Ember is the default.** The owner's choice of Twilight and Harbor gold accents overrides the earlier "no gold" note (FR-22).

The 24 older themes stay behind "More themes" in Settings → Appearance: Organic (`sage`), Mint, Sky, Blossom, Citrus, Peach, Ocean, Desert, Emerald, Rose, Dusk, Slate, Lavender, Sunrise, Indigo, Mono, Andalus, Olive, Forest, Coral, Plum, Sand, Night and Midnight. Each swaps the same token names, so no widget changes. All pass `python3 tool/contrast_check.py`. Exact values are in `lib/app/theme.dart`.

Picking a theme: the featured themes are a row of mini phone cards (each drawn from its own palette: header wash, habit pills, mood dots, a button) that grow and glow when chosen. The first-run "Pick your colours" step shows a live preview above them where three habits tick themselves, the counter pops and confetti plays, so the app shows off its motion while you choose. Phones set up before this step was redone see it once (`themePicked2`).

Each bright theme is a pair of OKLCH hues, a main colour (habits, checks, tabs) and a warm second voice (buttons, kickers): Mint 165/25, Sky 235/65, Blossom 350/145, Citrus 115/60, Peach 45/195. Light tokens follow the design formulas (`bg` L97.5 C.018 on the main hue, `surface` 93/.035, `divider` 86/.04, `neutral-100` 99/.008, `accent-2-200…900` 91/.06, 86/.09, 77/.12, 55/.13, 30/.07, `accent-200/400/700/900` on the second hue 93/.05, 76/.13, 47/.13, 31/.08); the other neutrals and the dark sets are derived by us and not yet in the design.

Today's header sits on a soft diagonal wash from `sage200` to `accent200`, so every theme opens on its two colours.

## Motion
Durations: quick 150 ms, medium 250 ms, slow 400 ms. Settings → Appearance → Animations: Follow phone (default; off when Android's "Remove animations" is on), Always on, or Off (`MotionPref`, setting `motion`; `reduceMotion()` in `lib/widgets/motion.dart`). Used for:
- Screen open: cards fade, slide up and settle in turn (45 ms apart, first 8 only).
- Screen push: Android fade-forwards transition for More and Settings screens.
- Check-offs (habit row, habit day ring, prayer arc dot, mood dot): squash and pop with an elastic overshoot (650 ms), a wide ring and eight sparks, with a light haptic tick.
- Day complete (every habit and prayer logged, or every habit done): about 44 pieces of confetti in the theme's colours from two points, with gravity and spin (1.8 s), and a medium haptic; plays once when it turns complete.
- Today's header: a slow drifting gradient of the theme's two colours (8 s loop), still when motion is reduced.
- Count changes, "All done today", content card expand and tab changes fade, slide and scale.
- Weather icon (design §12): line icons drawn in code at stroke 2.75 on a 24-unit grid. The sun's rays turn once every 24 s, clouds drift ±1.5, rain and snow fall, lightning flickers every 3 s.
The weather icon and the header wash are the only loops, and both are slow.

## Right to left
Rows mirror automatically in Arabic and Urdu, and so do back chevrons. Media previous/next glyphs do not, so the Listen screen swaps them in RTL so the arrow points the way the button moves.

## Weather icon groups
Open-Meteo `weather_code` → icon: 0 clear; 1–2 partly cloudy; 3 cloudy; 45, 48 fog; 51–67 and 80–82 rain; 71–77, 85, 86 snow; 95–99 thunder; wind ≥ 40 km/h shows windy unless it is raining, snowing or thundering. The chip shows the icon, the temperature, `H 18° · L 9°` and `Light cloud · London`.

## Type
- Heading font (`--font-heading`): **Caprasimo** (one heavy weight, OFL), confirmed by the 26 Oct 2026 design export [OQ-9]. Fraunces stays selectable as "Soft serif".
- Arabic UI text: Noto Naskh Arabic (Amiri Quran stays for ayah text).
- Body: system sans (Roboto) at 15px base.
- Arabic: **Amiri Quran**, 22px, line-height 1.9, RTL.
- Sizes: screen title 28, section 19, card body 15, meta 12–13, small 11.

## Radii and spacing
- `radius-md` 12, `radius-lg` 20, pills 999. Calendar cell 16.
- Screen padding 20 horizontal; section gap 18; card gap 8–10.
- Min touch target 48 (nav, mood, switch), inputs 44.

## Components
Card (surface, radius-lg, padding 16), kicker (uppercase small, letter-spaced), tag (`tag-accent`, `tag-accent-2`), ghost/primary/secondary/icon buttons, segmented control, switch, pill habit row, mood picker, 7-day ring row, calendar cell, stat card, bar chart, progress bar, bottom nav with pill + label.
