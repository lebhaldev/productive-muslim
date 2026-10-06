# 01 — Functional specification

Status: v0.2, synced to design export `design/2026-10-05-Nurday.dc.html`. Tags: **[D]** = defined by the design, **[B]** = brief only (not in design), **[OQ-n]** = open question in [05-design-sync.md](05-design-sync.md).

## 1. Product

- **Promise:** open the app in the morning, see the day (weather, ayah, hadith, quote), check habits, log what you did and how you felt, write a journal tied to that date. Any past day can be reopened.
- **Primary user:** a Muslim who wants faith content and a simple daily log in one place.
- **Secondary user:** wants habits, journal, mood and weather and hides the faith cards.
- **Platform:** Android first, Google Play. English UI, Arabic for ayah text.
- **Out of scope v1:** prayer times, qibla, adhan, full Quran reader, hadith search, social, cloud sync, accounts, payments, iOS, AI-written religious commentary.

## 2. Navigation [D]

Bottom bar, 5 tabs, each an icon in a pill plus a text label underneath. Active tab: sage pill and bold label.

| Tab | Icon | Screen |
|---|---|---|
| Today | ☀ sun | Today |
| Habits | ✓ check | Habits |
| Calendar | ▦ grid | Calendar |
| Journal | ✎ pencil | Journal (opens on today) |
| More | ⋯ | More list → Activities, Reflect, Settings (More stays highlighted on those) |

## 3. Today [D]

Order top to bottom:

1. **Header** — long date (`Monday 5 October`), then the Hijri date (`24 Rabi' Al-Thani 1448`) [FR-13], above `Good morning`. Weather chip on the right (sage background): current temp large, `H 18° · L 9°`, `<condition> · <city>`. Greeting by time of day [OQ-16].
2. **Prayer times card** [FR-12]: next prayer name, time and `in 1 h 20 min`; a row of the five prayers (Fajr, Dhuhr, Asr, Maghrib, Isha) with the next one highlighted, plus sunrise. Without a location: `Set your city in Settings to see prayer times.` Hidden with the faith cards.
3. **Faith cards** (hidden when "Show faith cards" is off): Ayah of the day, Hadith of the day.
4. **Quote of the day** card (always shown; in the design it sits in the same list as the faith cards, so it is hidden with them [OQ-17]).
5. **Habits** — heading + `N of M`. Pill rows: empty ring or filled sage check, name, streak `3 days` / `1 day` / nothing at 0.
6. **How do you feel?** — 5 mood dots with labels. Selected dot grows (32→40) with a dark ring and bold label.
7. **Today's activity** — `+ Log` opens Activities. Rows `06:30  Title  25 min`, sorted by time. Empty: `Nothing logged yet.`
8. **Journal shortcut** (peach) — `Write today's journal` / `A few lines is enough.`; once an entry exists: `Continue today's journal` / title or first 40 chars of body + `…`. Opens Journal on today.
9. **Cache note** — `Content and weather updated HH:mm · works offline`.

### Content cards [D]
- Header: kicker (`Ayah of the day`, `Hadith of the day`, `Quote of the day`) in terracotta, `More` / `Less` toggle on the right. Tapping anywhere on the card toggles. Only one card open at a time.
- Ayah: Arabic block (Amiri Quran, RTL, light tinted box), English translation, source `Surah <name> <s>:<v> · <translator>`.
- Hadith: Arabic text first (RTL box, as for the ayah), then the English translation unless the content language is `Arabic only`; source `<collection> · Book <n> · No. <n>`.
- Quote: Arabic text (verse lines on separate lines, RTL box), `<author> · <work>`; expanded reference `OpenITI corpus · <page> · <source file>`.
- Expanded: a tag (`App summary — not tafsir` for ayah, `App summary` for hadith, `Encouragement, not scripture` for quote), the note, and a reference line (ayah: `Edition: quran-uthmani + en.sahih · fetched 06:58`; hadith: `Grading per source · sunnah.com reference`).

## 4. Habits [D]
- `New habit` input + `Add` button.
- One card per active habit: name, tag `3-day streak` or `Start today`; a 7-day row (6 days ago → `Today`, weekday initials) of rings, filled sage when done, each tappable to toggle that day; footer `Reminder HH:mm` or `No reminder`, buttons `↑` (move up), `Archive`, `Delete`.
- `Archived` section lists archived habits with `Restore`.
- Setting a reminder time per habit: not shown in the design [OQ-15].
- Delete has no confirmation in the prototype; the app asks for confirmation since it deletes history [OQ-18, default: confirm dialog].

## 5. Calendar [D]
- Title `October 2026`, `‹` `›` buttons. Cannot go past the current month.
- Weekday header Monday-first `M T W T F S S`.
- Cells (48 tall, rounded): day number; a mood dot (mood colour) and a small dark journal dot. Today: sage border, bold. Selected: light sage fill. Future days: faded and disabled.
- Legend `● mood  • journal`.
- Day detail card: date, mood tag (or `No mood`), Journal (`Title — body` or `No entry for this day.`), `Open journal` button, Habits completed (tags or `None`), Activities (`06:30  Title · 25 min` or `None logged`).
- `Open journal` opens the Journal on the selected day.

## 6. Journal [D]
- Header: `‹` prev day, `Journal` / `Mon 5 October`, `›` next day (not past today).
- `Title (optional)` field in heading font; body textarea with placeholder `What happened today? What are you grateful for?`.
- Autosaves on every change. Status line: `Saved on this phone · HH:mm`, or `Write something to save this day's entry.` when body is empty.
- An entry counts only when body is non-empty.

## 7. More [D]
List of large rows: `Prayer times — Today's times and Qibla`, `Activities — Log what you did, grouped by day`, `Reflect — Your last 30 days`, `Settings — Weather, prayer, reminders, theme, privacy`.

### Prayer times [new, not in design]
- Today's six times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha), the next highlighted, city and method under the title.
- Qibla card: bearing in degrees from true North and a compass rose with the Qibla arrow (static, no sensor) [FR-14].
- Without a location: the same prompt as Today and a `Open Settings` button.

### Activities [D]
- Form card: `What did you do?`, `Note (optional)`, start time (defaults to now), duration in `min` (default 30, min 1), button `Log activity` (disabled while title empty) / `Save changes` when editing.
- List grouped by day, newest first: `Today`, `Yesterday`, then `Monday 28 Sep`. Rows: time, title, `25 min`, `Edit`, `✕` delete.
- New activities are logged for today; editing keeps the original date [OQ-19].

### Reflect [D]
- Card `Mood · last 30 days`: 30 bars, height by mood value, colour by mood, grey stub for no mood; `30 days ago` … `Today`.
- Two stat cards: `N day journal streak`, `N entries this month`.
- Card `Habit check-offs · 30 days`: per active habit, name, count, progress bar (count/30).

### Settings [D]
- **Weather:** City override (text), note `Location is used only for weather (Open-Meteo).`, segmented `Celsius | Fahrenheit`. "Use my location" button not in design [OQ-20, default: add a small button].
- **Content:** switch `Show faith cards`; Translation select `Saheeh International` / `Dr. Mustafa Khattab, The Clear Quran`.
- **Appearance:** segmented `System | Light | Dark` (default System) [FR-15].
- **Prayer:** calculation method select (default Muslim World League), Asr select `Standard (Shafi'i, Maliki, Hanbali) | Hanafi`, high latitude rule `Middle of the night | Seventh of the night | Twilight angle`, switch `Prayer time notifications` (off by default; asks permission when turned on). Note `Times are calculated on this phone from your weather location.`
- **Content:** content language `Arabic + English | Arabic only` (default Arabic + English).
- **Reminders:** `Daily reminder` time (default 07:30); note `Per-habit reminders are set on each habit.`
- **Privacy card** (sage): `Your data stays on this phone` / `Journal, mood, habits and activities are never uploaded. No account needed.`
- **Sources & licenses** card.

## 8. Functional rules
- FR-1 **Local day key** `YYYY-MM-DD` in device time zone for every record.
- FR-2 **Stable daily content**: seeded by the day key, changes at local midnight.
- FR-3 **One journal per day**; saved only when body is non-empty.
- FR-4 **One mood per day**: rough, low, okay, good, bright (stored 0–4); tapping another replaces it.
- FR-5 **Streak**: consecutive done days ending today, or ending yesterday if today is not done yet.
- FR-6 **Counter**: done today / active habits.
- FR-7 **Journal streak**: same rule as FR-5 over days with a non-empty journal.
- FR-8 **Offline**: after one fetch, cached content and weather are shown with the update time.
- FR-9 **Hide faith cards** hides the content cards on Today.
- FR-10 **Privacy**: personal data never leaves the device; no account.
- FR-11 Calendar and Journal never navigate into the future.
- FR-12 **Prayer times** are computed on the device (adhan library) from the weather location, the chosen method and Asr madhab, in the device time zone. No network. Next prayer after Isha is tomorrow's Fajr.
- FR-13 **Hijri date** uses the Umm al-Qura calendar (hijri library). It can differ by a day from local moon sighting; the app does not claim otherwise.
- FR-14 **Qibla** is the great-circle bearing to the Kaaba from the weather location.
- FR-15 **Theme**: System follows the phone; Light/Dark override it. All colours come from tokens (03).

## 9. Content rules (non-negotiable)
- CR-1 Never invent an ayah, translation, tafsir, hadith, grading or chain. The design shows placeholders only, by intent.
- CR-2 Ayah: Uthmani Arabic + selected translation from AlQuran Cloud (`quran-uthmani` + `en.sahih` or `en.khattab` [OQ-11]).
- CR-3 Hadith: bundled cited dataset (120 items, Bukhari + Muslim), shows collection · book · number, the translator and, for Bukhari only, a sunnah.com link. No grading line: the source has none.
- CR-4 v1 ships no explanations. The expanded card shows only the reference. A note may be added later only when a person has reviewed it, labelled `App summary`, never as tafsir.
- CR-5 Quotes: Arabic only, from the OpenITI corpus (55 items, reviewer-verified), with author and work; labelled `Encouragement, not scripture`.
- CR-6 If a source fails with nothing cached, the card says which source failed. Never fill the gap.
- CR-7 Arabic: hadith Arabic is copied verbatim from the same dataset as the English (`ara-bukhari`, `ara-muslim`). Arabic quotes come only from a curated pool with author, work and a fetchable source; never machine-translated and attributed to someone. The English quote list was removed in v0.3.
