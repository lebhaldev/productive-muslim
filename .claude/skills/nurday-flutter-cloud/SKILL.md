---
name: nurday-flutter-cloud
description: How to build, test and visually check the Nurday Flutter app inside a Claude Code cloud container (no Flutter preinstalled, most APIs blocked, no emulator). Use at the start of any coding session on this repo, before running flutter, or when a test or CI run fails.
---

# Working on Nurday in a cloud container

## Setup (each new session)
```
tool/setup_flutter.sh            # installs the Flutter version pinned in CI into /opt/flutter
export PATH=/opt/flutter/bin:$PATH
```
"Woah! You appear to be trying to run flutter as root" is harmless noise.

## The loop before every push
```
dart format lib test tool
flutter analyze                  # must say "No issues found"
flutter test                     # all green
```
If the Drift schema changes: `dart run build_runner build --delete-conflicting-outputs` (CI fails if `database.g.dart` is stale).

CI (`.github/workflows/ci.yml`) also builds the debug APK, per-ABI release APKs and, with the upload key secrets, the Play bundle. Android builds cannot run in the container; check CI with the GitHub MCP tools (`actions_list` → `list_workflow_runs` on the branch, `get_job_logs` with `failed_only`). A run takes about 10 minutes; schedule a check-in instead of polling.

## Network reality
- Blocked: api.quran.com, api.alquran.cloud, open-meteo, hadeethenc, jsdelivr, api.github.com search.
- Allowed: raw.githubusercontent.com, pub.dev, pypi, storage.googleapis.com (Flutter SDK).
So the app's APIs are tested only with fixtures (`test/helpers.dart` → `fakeHttp`, `fixtureAssets`).

## Seeing the UI without a phone
`flutter test tool/screenshots_test.dart` writes PNGs of Today, the Settings menu and Appearance to `build/screenshots/`, then open them with the Read tool. It loads the app fonts; icons render as boxes. Use it after any layout change: it has caught tabs stacking vertically and a row overflowing by 15 px that tests alone did not describe.

## Widget-test habits that work here
- Use the `settle()` helper (15 × 100 ms pumps), never `pumpAndSettle` (Drift stream timers keep it spinning).
- Seed the database inside `tester.runAsync`; close it with `tester.runAsync(db.close)` after pumping `SizedBox()`.
- Before tapping something low on a screen: `scrollTo(...)` then `tester.ensureVisible(...)`; fixed-distance drags break when layouts change.
- Fakes live in `test/helpers.dart`: `FakeScheduler`, `FakeLock`, `FakeAuth`; `FakeBackupFiles` lives in `app_flow_test.dart`. Platform plugins (file picker, local_auth, Google sign-in) are always behind a provider so tests can override them.
- Open Settings in tests with the `openSettings(tester, '<section id>')` helper.
