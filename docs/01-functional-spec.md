# 01 — Functional specification

Status: v0.2, synced to design export `design/2026-10-05-Nurday.dc.html`. Tags: **[D]** = defined by the design, **[B]** = brief only (not in design), **[OQ-n]** = open question in [05-design-sync.md](05-design-sync.md).

## 1. Product

- **Promise:** open the app in the morning, see the day (weather, ayah, hadith, quote), check habits, log what you did and how you felt, write a journal tied to that date. Any past day can be reopened.
- **Primary user:** a Muslim who wants faith content and a simple daily log in one place.
- **Secondary user:** wants habits, journal, mood and weather and hides the faith cards.
- **Platform:** Android first, Google Play. English UI, Arabic for ayah text.
- **Out of scope v1.1:** lessons, points, levels, app-written explanations or guided sessions (see research/balum-review.md).
- **Out of scope v1:** prayer times, qibla, adhan, full Quran reader, hadith search, social, accounts (Google is used only to reach the user's own Drive), payments, iOS, AI-written religious commentary.

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

1. **Header** — long date (`Monday 5 October`), then the Hijri date (`24 Rabi' Al-Thani 1448`) [FR-13], above `Good morning`. Weather chip on the right (sage background): current temp large, `H 18° · L 9°`, `<condition> · <place>`, where place is the picked city or the name the phone gives "Use my location" (never `My location` when a name is available). Greeting by time of day [OQ-16].
2. **Prayer times card** [FR-12]: next prayer name, time and `in 1 h 20 min`; a row of the five prayers (Fajr, Dhuhr, Asr, Maghrib, Isha) with the next one highlighted, plus sunrise. Without a location: `Set your city in Settings to see prayer times.` Hidden with the faith cards.
3. **Faith cards** (hidden when "Show faith cards" is off): Ayah of the day, Hadith of the day.
4. **Quote of the day** card (always shown; in the design it sits in the same list as the faith cards, so it is hidden with them [OQ-17]).
5. **Habits** — heading + `N of M`. Pill rows: empty ring or filled sage check, name, streak `3 days` / `1 day` / nothing at 0.
6. **How do you feel?** — 5 mood dots with labels. Selected dot grows (32→40) with a dark ring and bold label.
7. **Today's activity** — `+ Log` opens Activities. Rows `06:30  Title  25 min`, sorted by time. Empty: `Nothing logged yet.`
8. **Journal shortcut** (peach) — `Write today's journal` / `A few lines is enough.`; once an entry exists: `Continue today's journal` / title or first 40 chars of body + `…`. Opens Journal on today.
9. **Cache note** — `Content and weather updated HH:mm · works offline`.

### Content cards [D]
- Three cards, all visible at once (user request 2026-10-07; tabs removed): kicker (`Ayah of the day`, `Hadith of the day`, `Quote of the day`) and a `Show another` ↻ button on the right. Tapping a card opens or closes it; each opens on its own.
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

## 7b. v1.1 features (planned 2026-10-16, from the Balum review) [OQ-27]

Decided in [research/balum-review.md](research/balum-review.md). Not built yet; screens wait for the design brief `design/2026-10-16-design-brief.md`.

- **Prayer log and day line** [FR-16]: the next-prayer card and the Prayer screen show a gentle arc from Fajr to Isha with the five prayers on it and sunrise and sunset marked. Logged prayers are filled sage, the next has a ring, others are empty. Tapping a prayer logs or unlogs it (snackbar `Dhuhr logged` · Undo). Prayer screen rows show `Done`, `Next · in 1 h 12 min`, or nothing. Countdown in minutes only. A `Qibla` button opens the Prayer screen's Qibla card. Logged prayers appear as dots on Calendar and as a count in Reflect.
- **Gentle consistency** [FR-17]: habits show `N of the last 7 days` instead of a streak; Settings → Habits `Show consistency numbers` (on by default). Under the Habits heading: `N of M today` with a segmented bar over habits and logged prayers. A one-time dismissible card on Habits shows hadith `bukhari:6465` from the bundled dataset, full Arabic and English as in the dataset with its reference, with no app sentence tying it to the user's numbers.
- **Excused day** [FR-18]: a neutral `Excused today` link under Today's habits marks the day excused; it never counts against habits, prayers or consistency. No reason is stored.
- **Mood reply** [FR-19]: after a mood is picked, the mood card shows one fixed line and one suggestion for that mood (gratitude note, open journal, an unchecked habit) and `Not now`, which hides it for the day. Lines come from a fixed reviewed list in the app, never generated, with no religious promises and no mental-health advice; rough and low moods get a neutral action only. Mood-matched ayat (later) need tags set by a person, never an agent, and the card never shows the tag.
- **Mood week strip**: 7 dots (Mon–Sun) under the mood picker and at the top of Reflect; tapping a day opens it in Calendar.
- **Journal prompts and gratitude**: the body placeholder rotates daily through a fixed list (`What are you grateful for today?`, `What went well?`, `What weighed on you?`). A `Gratitude` block holds three optional short lines, stored with the day's entry; an entry with gratitude lines and an empty body counts as an entry (amends FR-3). Shown on the Calendar day.
- **Duas** [FR-20]: More → `Duas · Your own duas, private to this phone`. Add a dua (text, optional note); sections `Asking` and `Answered` with counts; `Mark answered` stores the date; Edit, Move back to Asking, Delete (confirm). Locked with the journal lock. Included in Export / Drive backup. The app never adds scripture to this list.
- **First run**: three skippable steps: location (city search or use location once), starter habits from six chips (Read Qur'an, Morning adhkar, Evening adhkar, Gratitude note, Call family, Walk), privacy promise.
- **Weekly review**: a Friday card on Reflect with plain counts (habits kept, prayers logged, mostly mood, journal days) and `Write a note to next week`, which opens the journal.
- **Arabic UI** [FR-21]: Settings → Appearance → Language `System | English | العربية`; mirrored RTL layout; only UI strings are translated, content stays verbatim.
- **Saved**: a bookmark on the ayah and hadith cards; More → `Saved` lists them with their references.

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
- FR-10 **Privacy**: personal data never leaves the device unless the user exports a backup file or connects Google Drive backup (own Drive, app folder only); no Nurday account or server.
- FR-11 Calendar and Journal never navigate into the future.
- FR-12 **Prayer times** are computed on the device (adhan library) from the weather location, the chosen method and Asr madhab, in the device time zone. No network. Next prayer after Isha is tomorrow's Fajr.
- FR-13 **Hijri date** uses the Umm al-Qura calendar (hijri library). It can differ by a day from local moon sighting; the app does not claim otherwise.
- FR-14 **Qibla** is the great-circle bearing to the Kaaba from the weather location.
- FR-15 **Theme**: System follows the phone; Light/Dark override it. All colours come from tokens (03).
- FR-16 **Prayer log**: one done/not-done mark per prayer per day key; no late, missed or congregation states; logging a future prayer of today is allowed only once its time has started.
- FR-17 **Consistency** = done days among the last 7 day keys, excused days removed from both counts.
- FR-18 **Excused day**: one boolean per day key, no reason field.
- FR-19 **No generated text**: mood replies, journal prompts and weekly card lines are fixed strings in the app, reviewed once; none quote or paraphrase scripture.
- FR-20 **Duas** are personal data: on device only, inside backups, behind the journal lock.
- FR-21 **Translation scope**: UI strings only. Ayah, hadith, tafsir and quote text are never machine-translated.
- FR-22 **Own identity**: no screen, label, illustration or store asset reuses another app's name, wording or visual identity (see research/balum-review.md §3).

## 9. Content rules (non-negotiable)
- CR-1 Never invent an ayah, translation, tafsir, hadith, grading or chain. The design shows placeholders only, by intent.
- CR-2 Ayah: Uthmani Arabic + selected translation from AlQuran Cloud (`quran-uthmani` + `en.sahih` or `en.khattab` [OQ-11]).
- CR-3 Hadith: bundled cited dataset (120 items, Bukhari + Muslim), shows collection · book · number, the translator and, for Bukhari only, a sunnah.com link. No grading line: the source has none.
- CR-4 The app never writes explanations. Ayah: the opened card shows published tafsir copied verbatim from a bundled dataset (Al-Mukhtasar in English by the Tafsir Center for Quranic Studies; Tafsir Al-Muyassar in Arabic by the King Fahd Complex; `assets/content/tafsir.json`), with its name and author. Hadith: no reviewed explanation source is bundled yet, so the card says so. Quote: none.
- CR-8 "Show another" (↻ on the content card) moves to the next item of the same pool for today only; the next day starts again from the daily pick. Nothing is fetched or generated outside the existing pools.
- CR-5 Quotes: Arabic only, from the OpenITI corpus (55 items, reviewer-verified), with author and work; labelled `Encouragement, not scripture`.
- CR-6 If a source fails with nothing cached, the card says which source failed. Never fill the gap.
- CR-7 Arabic: hadith Arabic is copied verbatim from the same dataset as the English (`ara-bukhari`, `ara-muslim`). Arabic quotes come only from a curated pool with author, work and a fetchable source; never machine-translated and attributed to someone. The English quote list was removed in v0.3.
