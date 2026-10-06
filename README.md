# Nurday

A calm, local-first Android app for Muslims who want a daily rhythm: one sourced ayah, one sourced hadith and a short quote, habit check-offs with streaks, mood, an activity log, a daily journal, weather, and a calendar that opens any past day.

Built with Flutter from the Claude Design prototype in [`docs/design/`](docs/design/). Specs live in [`docs/`](docs/README.md).

## What it does
- **Today**: date and Hijri date, greeting, weather; next prayer with a countdown and the day's times; Ayah, Hadith (Arabic + English) and Quote cards with sources (tap to expand); habits with streaks; one-tap mood; today's activities; journal shortcut.
- **Habits**: add, archive, restore, reorder, delete; last 7 days tappable; optional reminder time.
- **Calendar**: month grid with mood and journal marks; tap a day to see its journal, mood, habits and activities.
- **Journal**: one entry per day, autosaved.
- **Reminders**: a daily reminder and optional per-habit reminders, as local notifications.
- **Prayer times**: computed on the phone (adhan), method and Asr madhab in Settings, optional notifications, Qibla bearing.
- **Dark theme**: System, Light or Dark in Settings.
- **More**: Prayer times, Activities (log, edit, delete, grouped by day), Reflect (30-day mood, journal streak, habit counts), Settings.

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
| Daily ayah pool | `assets/content/ayah_refs.json`, 120 references only, validated against verse counts | — |
| Hadith | 120 hadith (70 Sahih al-Bukhari, 50 Sahih Muslim), Arabic (`ara-bukhari`, `ara-muslim`) and English text copied verbatim from [fawazahmed0/hadith-api](https://github.com/fawazahmed0/hadith-api) and verified byte for byte. Translators: Muhammad Muhsin Khan (Bukhari), Abdul Hamid Siddiqui (Muslim). Bukhari items link to sunnah.com; Muslim items show the Abdul-Baqi number without a link. No grading is shown because the source has none. | Dataset: Unlicense (see `assets/content/HADITH-LICENSE.txt`). The translations themselves may be under their translators' copyright: confirm before a Play release. |
| Quotes | `assets/content/quotes.json`, 34 quotes, each with author and work (proverbs show Unknown) | Public domain / short quotation |
| Prayer times, Qibla | Calculated on the phone with [adhan](https://pub.dev/packages/adhan) | MIT |
| Hijri date | Umm al-Qura via [hijri](https://pub.dev/packages/hijri) | MIT |
| Weather | [Open-Meteo](https://open-meteo.com) | CC BY 4.0 |
| Fonts | Amiri Quran, Fraunces | SIL Open Font License |

No explanations ship in v1. An expanded card shows only its reference; explanations will be added only after a person has reviewed them. The Clear Quran translation is coded but hidden until its licence and endpoint are confirmed.

## Offline behaviour
- Journal, mood, habits and activities live in a local SQLite database (Drift) and work with no network.
- The day's ayah is cached after the first fetch. Offline, the last saved ayah is shown with its fetch time; if nothing was ever fetched, the card names the source that failed and shows nothing in its place.
- Hadith and quotes are bundled and always available.
- The last weather snapshot is shown with its update time.

## Publishing
The app is not on Google Play. Submitting it needs a human with a Google Play Console developer account (one-time $25 fee), an upload keystore kept outside this repo, and the privacy policy ([PRIVACY.md](PRIVACY.md)) hosted at a public URL. See `docs/04-dev-plan.md`, Phase 5.
