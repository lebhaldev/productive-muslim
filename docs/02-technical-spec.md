# 02 — Technical specification

Status: v0.2, 2026-10-05 (synced to full design export).

Build environment note: the cloud container cannot reach AlQuran Cloud, Open-Meteo or the Android SDK host, so local runs use `flutter test` with fixtures; APK builds and integration tests run in GitHub Actions.

## 1. Stack

| Concern | Choice |
|---|---|
| Framework | Flutter stable, Material 3, Dart null-safe |
| State | Riverpod (code-gen providers) |
| Navigation | GoRouter with a `StatefulShellRoute` for the 5 tabs |
| Database | Drift (SQLite), one database file |
| Notifications | flutter_local_notifications + timezone |
| Location | geolocator, with manual city fallback |
| Weather | Open-Meteo forecast + geocoding API (no key) |
| Quran | AlQuran Cloud (`api.alquran.cloud/v1/ayah/{ref}/editions/quran-uthmani,en.sahih`) editions `en.sahih` (default) and `en.khattab` |
| Hadith | Checked-in JSON subset of Bukhari/Muslim from a licensed dataset (e.g. `fawazahmed0/hadith-api`, Unlicense) with collection, book, number, English text, source URL [OQ-12] |
| Quotes | Checked-in `assets/quotes.json` (text, author or null, source) |
| Package id | `com.nurday.app` |
| Min / target SDK | minSdk 24, targetSdk = current Play requirement |

## 2. Architecture

```
lib/
  app/            router, theme (tokens from 03-design-system), app.dart
  core/           day_key.dart, clock.dart, result types
  data/
    db/           drift tables, DAOs, migrations
    content/      quran_client.dart, hadith_repository.dart, quote_repository.dart
    weather/      open_meteo_client.dart
    repositories/ habit, activity, mood, journal, content, weather, settings
  features/
    today/ habits/ activities/ journal/ calendar/ reflect/ settings/
  l10n/
assets/
  hadith/ quotes.json fonts/
test/ integration_test/
```

Layering: widgets → Riverpod providers → repositories → Drift DAOs / HTTP clients. Widgets never hold religious text.

## 3. Data model (Drift)

| Table | Columns |
|---|---|
| `habits` | id PK, name, archived bool, sortOrder int, reminderTime text? (`HH:mm`), createdAt |
| `habit_completions` | habitId FK, dayKey text, PK(habitId, dayKey) |
| `activities` | id PK, title, note?, startTime text `HH:mm`, durationMinutes int, dayKey |
| `moods` | dayKey PK, value int 0–4 (rough→bright), note?, updatedAt |
| `journals` | dayKey PK, title?, body, createdAt, updatedAt |
| `content_cache` | dayKey, kind (`ayah`/`hadith`/`quote`), payload JSON, fetchedAt, PK(dayKey, kind) |
| `weather_cache` | id PK=1, locationLabel, payload JSON, fetchedAt |
| `settings` | key PK, value JSON |

`dayKey` is `YYYY-MM-DD` from local time. Primary keys on `dayKey` enforce one mood and one journal per day at the database level.

Content payload must include: `text`, `arabic` (ayah), `translator`/`edition`, `surah`/`verse` or `collection`/`book`/`number`, `sourceUrl`, optional `explanation` with `explanationSource` (`null` ⇒ rendered as "App summary").

## 4. Daily content selection

- Seed = `dayKey` hashed (stable FNV-1a) → index.
- Ayah: index into a curated list of ayah references (`assets/ayah_refs.json`, references only, no text), text fetched once from AlQuran Cloud and cached in `content_cache`.
- Hadith: index into the bundled dataset; no network needed.
- Quote: index into `quotes.json`.
- On app resume, if `dayKey` changed, recompute.

## 5. Technical rules

- TR-1 No religious text literal in `lib/`. A test scans `lib/**.dart` for Arabic script and known hadith/ayah strings and fails if found.
- TR-2 All religious strings rendered in widget tests come from fixtures under `test/fixtures/`.
- TR-3 Every network fetch writes to cache before UI reads it; UI reads only from cache (single source of truth).
- TR-4 Network failures return a typed error naming the source (`AlQuranCloud`, `OpenMeteo`); UI shows it with the last cached timestamp.
- TR-5 Date logic goes through `Clock` + `dayKey()`; never `DateTime.now().toUtc()` for day boundaries.
- TR-6 All colours and text styles come from theme tokens; no hex literals in feature widgets.
- TR-7 No secrets, keystores or API keys in the repo. `key.properties` and `*.jks` are gitignored.
- TR-8 Location is requested only when the user taps "Use my location"; coordinates are only sent to Open-Meteo.
- TR-9 Only network hosts allowed: AlQuran Cloud (or Quran.com), Open-Meteo. No analytics SDKs.
- TR-10 `flutter analyze` clean and all tests green before each phase is closed.
- TR-A1 Accessibility: semantic labels on every icon button, nav tab and mood dot; text scales to 200% without clipping; contrast ≥ 4.5:1 for body text.

## 6. Testing

- Unit: `dayKey`, streaks (incl. midnight and DST), counter, one-journal-per-day, content seed stability, cache fallback.
- Widget: Today renders cards from fixtures; habit toggle updates counter and streak; mood selection; hide-faith-cards.
- Integration (emulator): fresh install → log habit, activity, mood, journal → restart offline → Calendar day shows all four.
- Golden tests for Today against the design snapshot once tokens are final.

## 7. Additions in v0.3
- `adhan` (Dart port of adhan-js) computes prayer times and the Qibla bearing on the device. Methods offered: Muslim World League (default), Egyptian, Karachi, Umm al-Qura, Dubai, Qatar, Kuwait, Moonsighting Committee, Singapore, Turkey, Tehran, North America (ISNA). Asr: Shafi'i (standard) or Hanafi.
- `hijri` (Umm al-Qura) for the Hijri date.
- Settings keys: `themeMode` (system|light|dark), `prayerMethod`, `madhab` (shafi|hanafi), `prayerAlerts` (true|false), `contentLanguage` (ar_en|ar).
- Prayer notifications: one-off notifications for the next 7 days (ids 2000–2034), rebuilt on every sync (app start, resume, settings change). Inexact, like the other reminders.
- Hadith JSON gains `arabic` (verbatim from `ara-<collection>` in fawazahmed0/hadith-api@1, same hadith number, reference checked equal by the reviewer's build script).
- Dark theme: the palette is a `ThemeExtension`-free token set swapped at the app root; the app subtree is rebuilt when brightness changes.
- Release APKs: CI builds `--release --split-per-abi --obfuscate`; arm64 APK is the one to install.
