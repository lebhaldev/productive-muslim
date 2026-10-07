# 04 — Development, test and release plan

Each phase ends with `flutter analyze` clean, tests green, and a short entry in `CHANGELOG.md`. A phase that touches an undesigned screen waits for that design, or ships a plain Material version marked "pending design".

## Phase 0 — Setup (needs the user)
- GitHub repository `nurday` connected to this project (none attached yet).
- Decide on open questions OQ-11 and OQ-12 (content sources).
- Design export of `Nurday.dc.html` dropped into the thread (see 05-design-sync).

## Phase 1 — Shell and local data
- Flutter project, theme tokens from 03-design-system, GoRouter 5-tab shell.
- Drift schema and repositories (02 §3).
- Today screen layout matching the design, with empty states.
- Tests: dayKey, streak, one journal per day.

## Phase 2 — Trackers
- Habit toggle, counter, streaks; Habits screen CRUD, archive, reorder.
- Mood picker; activity log with `+ Log`; journal editor with autosave.
- Calendar month grid with mood colours, journal mark, day detail.
- Integration test: mark habit → restart → calendar day shows it.

## Phase 3 — Daily content and weather
- Ayah client + cache, bundled hadith dataset, quotes.json.
- Expandable cards with sources, "App summary" labelling.
- Hide-faith-cards setting; weather via location or typed city.
- TR-1/TR-2 tests (no hardcoded scripture).

## Phase 4 — Reminders and polish (done)
- Daily and per-habit reminders, Reflect screen, accessibility pass, app icon, splash.

## Phase 4b — v0.3 (2026-10-06, user request)
- Arabic hadith text (CR-7), Arabic quotes once the reviewer's cited pool lands.
- Dark theme with provisional tokens (03), Appearance setting.
- Prayer times on Today and a Prayer times screen, method/madhab settings, optional prayer notifications.
- Hijri date in the header, Qibla bearing.
- Small release APKs split per CPU type, published by CI.

## Phase 5 — Play-ready, stop before submit
Status (v0.3.0): agent side done — upload-key signing (`key.properties` / CI secrets), `.aab` built in CI when the key exists, RELEASE.md, Data safety draft, store listing draft (`docs/store-listing.md`). Waiting on the human steps in RELEASE.md.

- Release `.aab`, versioning, adaptive icon.
- `PRIVACY.md`, Data safety notes (location optional for weather; personal data stays on device), content rating notes.
- Store listing copy and screenshot list.
- `RELEASE.md` with the human steps: Play Console account ($25), upload keystore kept outside the repo, privacy policy at a public URL, Data safety and content rating forms, internal testing track, then production.

An agent never buys the Play Console account, uploads a release, or stores a keystore password.

## Done when
- Fresh install, offline after first run: habit, activity, mood, journal logged and visible on that Calendar day after restart.
- With network: Today shows weather plus ayah and hadith with source metadata.
- README run steps work on an emulator.
- Release bundle and RELEASE.md exist; nothing claims the app is live on Play.

## How testing runs here
Builds and tests run in the cloud container (Flutter SDK + Android SDK installed per session) and in GitHub Actions on every PR: `flutter analyze`, `flutter test`, and `flutter build appbundle --debug`. Emulator integration tests run in CI; manual testing on a phone uses the debug APK attached to each PR.
