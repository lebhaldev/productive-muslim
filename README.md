# Nurday

A calm, local-first Android app for Muslims who want a daily rhythm: one sourced ayah, one sourced hadith and a short quote, habit check-offs with streaks, mood, an activity log, a daily journal, weather, and a calendar that opens any past day.

Built with Flutter from the Claude Design prototype in [`docs/design/`](docs/design/). Specs live in [`docs/`](docs/README.md).

## What it does
- **Today**: date, greeting, weather; Ayah, Hadith and Quote cards with sources (tap to expand); habits with streaks; one-tap mood; today's activities; journal shortcut.
- **Habits**: add, archive, restore, reorder, delete; last 7 days tappable; optional reminder time.
- **Calendar**: month grid with mood and journal marks; tap a day to see its journal, mood, habits and activities.
- **Journal**: one entry per day, autosaved.
- **More**: Activities (log, edit, delete, grouped by day), Reflect (30-day mood, journal streak, habit counts), Settings.

## Run it
Requirements: Flutter 3.47 stable, Android SDK, an emulator or a phone with USB debugging.

```sh
flutter pub get
flutter run            # on a connected device or emulator
flutter test           # unit and widget tests
flutter build apk --debug
```

The Drift database code (`lib/data/db/database.g.dart`) is committed. After changing tables, regenerate it with `dart run build_runner build`.

Every pull request builds a debug APK in GitHub Actions (artifact `nurday-debug-apk`), so you can install it on a phone without a local setup.

## Content sources
Nurday never generates religious text. Everything shown comes from these sources, and widgets only display what the data layer loads.

| Content | Source | Licence |
|---|---|---|
| Ayah, Arabic Uthmani + Saheeh International | [AlQuran Cloud API](https://alquran.cloud/api) (`quran-uthmani`, `en.sahih`) | Per AlQuran Cloud terms |
| Ayah, The Clear Quran (optional) | [Quran.com API v4](https://api-docs.quran.com/) translation 131 | Per Quran.com terms |
| Daily ayah pool | `assets/content/ayah_refs.json`, references only | — |
| Hadith | 24 hadith from Sahih al-Bukhari, English text copied verbatim from [fawazahmed0/hadith-api](https://github.com/fawazahmed0/hadith-api) edition `eng-bukhari`, with links to sunnah.com | Unlicense (public domain), see `assets/content/HADITH-LICENSE.txt` |
| Quotes | `assets/content/quotes.json`, each with author and publication | Public domain / short quotation |
| Weather | [Open-Meteo](https://open-meteo.com) | CC BY 4.0 |
| Fonts | Amiri Quran, Fraunces | SIL Open Font License |

Explanations ("App summary") are not shipped yet: the expanded card says no summary has been reviewed, rather than inventing one.

## Offline behaviour
- Journal, mood, habits and activities live in a local SQLite database (Drift) and work with no network.
- The day's ayah is cached after the first fetch. Offline, the last saved ayah is shown with its fetch time; if nothing was ever fetched, the card names the source that failed and shows nothing in its place.
- Hadith and quotes are bundled and always available.
- The last weather snapshot is shown with its update time.

## Publishing
The app is not on Google Play. Submitting it needs a human with a Google Play Console developer account (one-time $25 fee), an upload keystore kept outside this repo, and the privacy policy ([PRIVACY.md](PRIVACY.md)) hosted at a public URL. See `docs/04-dev-plan.md`, Phase 5.
