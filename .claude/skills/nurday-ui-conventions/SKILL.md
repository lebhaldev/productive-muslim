---
name: nurday-ui-conventions
description: Nurday's code and UI conventions — colour tokens and themes, motion, shared widgets, settings sections, providers, privacy defaults. Use when adding or changing any screen, setting, theme, animation or feature in this repo.
---

# Nurday UI and code conventions

## Layout of the code
- `lib/app/` — router, theme (palettes + `ColorTheme`), providers, `AppSettings` (typed view over the key/value settings table).
- `lib/data/` — database (Drift), backup, Drive, content, prayer, reminders, app lock. Platform plugins sit behind a provider so tests can fake them.
- `lib/features/<area>/` — screens. Settings: one file per section in `lib/features/settings/`, registered in `settingsSections`.
- `lib/widgets/common.dart` — reuse before writing new: `ScreenBody`, `ScreenTitle`, `SubScreenTitle`, `NCard` (`animateSize` for expanding cards), `NavRow`, `ActionTile`, `ArabicBlock`, `Kicker`, `Tag`, `Note`, `CardTitle`. `lib/widgets/motion.dart` — `motion()`, `PopSwitcher`, `FadeOnChange`.

## Colours and themes
- Feature widgets use `AppColors.<token>` only, never hex (TR-6). The app root swaps `AppColors.current` and rebuilds the tree.
- A theme is a `Palette` (light + dark) plus a `ColorTheme` entry. After adding or editing one, run `python3 tool/contrast_check.py`; every pair must pass (text 4.5:1, check mark 3:1).
- The design (Claude Design file) wins on look; anything not designed is provisional and gets an OQ row in `docs/05-design-sync.md`.

## Motion
Every duration goes through `motion(context, Motion.quick|medium|slow)`, which returns zero when Android's "Remove animations" is on. Keep motion calm: fades, small scale pops, `AnimatedSize`.

## Adding a setting
1. Getter on `AppSettings` (`lib/app/app_settings.dart`) with a safe default.
2. Control in the right section file using `SettingSwitch`, `SettingPicker`, `SettingChoice`; save with `ref.putSetting(key, value)`; notification toggles use `ref.setNotifying(key, on, what)`.
3. If it changes data leaving the phone, update PRIVACY.md, FR-10/TR-9 and RELEASE.md's Data safety table.

## Today screen
Keep it calm: header (date · Hijri, greeting, weather, settings gear), compact next-prayer card, one tabbed content card, habits, mood, then Journal + Activity tiles. New things go to More or Settings unless the user asks for them on Today.

## Privacy defaults
Local-first: no account, no server, no analytics. Anything that sends data off the phone is opt-in, explained in plain words where it is turned on, and reversible.

## Done means
Format, `flutter analyze` clean, tests green (add a widget test for each new flow), screenshot check for layout changes, CHANGELOG entry, specs/OQs updated, commit with a clear message, CI green.
