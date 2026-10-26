# Changelog

## 1.1.0 (unreleased)
- Synced to the v1.1 design export of 26 October (`docs/design/2026-10-26-Nurday-v1.1.html`): Caprasimo is the Classic heading font (Fraunces stays as "Soft serif"); Organic dark and the five bright themes use the design's colour values; the weather chip shows an animated line icon (sun, partly cloudy, cloud, fog, rain, snow, thunder, wind of 40 km/h or more) with today's high and low, still when "Remove animations" is on; the prayer card reads "Prayer today" with sunrise and sunset ticks under the arc, a "now" dot, "Asr · 15:58 · in 1 h 12 min" and a Qibla pill; the Prayer screen lists the times as pill rows with "Calculated on this phone · method · place"; habit cards show "N of the last 7 days" beside the name, seven large day pills and a ⋯ menu (reminder, move up, archive, delete).
- Five brighter themes: Mint, Sky, Blossom, Citrus and Peach, each light and dark (17 in all), all passing the contrast check. The first theme is now called Organic, as in the design system.
- More life: Today's header sits on a soft wash of the theme's two colours; cards fade up in turn when a screen opens; More and Settings screens slide in; checking a habit or prayer pops with a spreading ring and a light haptic tick; finishing every habit and prayer for the day plays a short burst of theme-coloured dots. All motion stops when Android's "Remove animations" is on.
- First run has a "Pick your colours" step: the swatches, System / Light / Dark and a live preview card. Phones set up before this see that one step once.
- Prayer log (FR-16): the next-prayer card and the Prayer screen show the day as an arc from Fajr to Isha with sunrise and sunset marked; tap a prayer that has started to log it (snackbar with Undo). Prayer rows show `Done` or `Next · in …`, never "missed". A Qibla button on the card. Logged prayers show on Calendar (a small sage bar and a "Prayers logged" line on the day) and as a monthly count in Reflect.
- Gentle consistency (FR-17): habits show `N of the last 7 days` instead of a streak (Settings → Habits → Show counts, on by default). Today's Habits heading shows `N of M today` with a segmented bar over habits and logged prayers. The Habits screen has the same count and bar under its title. A one-time card on Habits ("On small deeds") shows Sahih al-Bukhari 6465 from the bundled dataset, Arabic and English as in the dataset, with its reference; close it and it stays closed.
- Excused day (FR-18): an `Excused today` link under Today's habits marks the day excused, with no reason asked; it is left out of consistency counts and the bar. The day then shows a quiet card with an `Excused today` tag, `Undo`, and "Today won't count for habits or prayers. You can still check things off."
- Mood reply (FR-19): after a mood is picked, Today shows one fixed line and one suggestion in a tinted card: rough "That sounds heavy. Go gently today." (Take a slow walk), low "Thanks for noticing it." (Open today's journal), okay "An ordinary day is fine." (Log one small thing you did), good "Glad to hear it." (Write one thing you're grateful for), bright "Lovely. Hold on to it." (Note what made today good). `Not now` hides it until tomorrow or until the mood changes, leaving a short "Saved" line. All lines live in `lib/core/copy.dart`.
- Mood week strip ("This week"): seven dots labelled Mon to Sun with today underlined, under the mood picker and at the top of Reflect; tapping a day opens it in Calendar (on that day's month).
- Duas (FR-20): More → Duas, your own duas on this phone. Add one from a single field; `Asking` and `Answered` sections with counts; ✓ marks it answered with the date, answered rows are tinted and ↺ moves one back; the ⋯ menu has Edit (with an optional note), Move back to Asking and Delete ("It's removed from this phone. This can't be undone."). A small sprig at the top gains a leaf per answered dua, up to 12. Locked state: "Duas are locked · Same lock as your journal." Locked with the journal lock and included in Export and Drive backup. The app never adds text to this list.
- Journal: a tinted `Gratitude` card with three optional numbered lines above the body, saved with the day's entry (gratitude lines alone count as an entry) and listed under "Grateful for" on the Calendar day. The body placeholder rotates daily through three fixed prompts. The journal now scrolls as one page.
- First run: a fresh install opens four skippable steps with progress pills, `Skip` top right and one wide button at the bottom: Where are you? (Continue), Pick a few habits from six chips (Add N habits), Pick your colours, and the privacy promise (Start my day). Phones upgrading from 1.0 only get the colour step, once.
- Weekly review: from Friday until Thursday night, Reflect opens with a card ("Your week · 17–23 Oct") of plain counts for the Saturday to Friday week (habits kept, prayers logged, mostly mood, journal days) and `Write a note to next week`, which opens today's journal. No scores and no religious wording.
- Saved: a bookmark on the ayah and hadith cards; More → Saved lists them with their references (saved hadith show their bundled text, offline).
- Arabic UI, first part (FR-21): Settings → Appearance → Language (System, English, العربية). Picking Arabic mirrors the layout right to left. Strings now come from `lib/l10n/app_en.arb` and `app_ar.arb` (tab bar, Today headings, the habits bar, the language picker so far; the rest still to move). The Arabic strings are a draft waiting for a native speaker's review, so "System" stays English on Arabic phones until `arabicUiReviewed` is set. Content text is never translated.
- Database schema 2 (prayer logs, excused days, duas, saved items, journal gratitude) with an add-only upgrade and a migration test from the released schema 1.
- Backup format 2 includes the new data; format 1 files still import.

## 1.0.1 (11 October 2026)
- Removes the advertising ID permission (`AD_ID`) in case a library adds it, matching Play's "No" Advertising ID declaration; a test and a CI check on the release APK keep it out.
- docs/play-console.md records what was set up in Play Console (internal testing track, declarations, Data safety, listing).

## 1.0.0 (10 October 2026)
First Play Store release, published by Leb Apps.
- Prayer alerts fire on the exact minute when Android's "Alarms & reminders" is allowed (Settings → Prayer → Allow on-time alerts); otherwise Android may delay them a few minutes. Declares `SCHEDULE_EXACT_ALARM`, not `USE_EXACT_ALARM`.
- Settings → Prayer: Send a test notification; Hijri date offset (±2 days); "Adjust times to match your mosque" shifts each prayer by up to ±30 minutes.
- Android's automatic Google backup and device transfer are off (`allowBackup="false"`, data extraction rules), so personal data leaves the phone only through Nurday's own opt-in backups. A test keeps it that way.
- Theme swatches in Settings → Appearance were empty; they show their colours again.
- Privacy policy and store listing name Leb Apps (lebapplications@gmail.com) as publisher and contact. Version 1.0.0+4.

## 0.3.0
- Today shows the ayah, hadith and quote together again, each in its own card with its own ↻ Show another, instead of tabs.
- Location: Settings → Location has a city search with suggestions (name, region, country). The weather chip and prayer card show the real place name; "Use my location" asks the phone's geocoder for the name, and locations saved earlier are named once.
- Four more colour themes: Lavender, Sunrise, Indigo and Mono (12 in all).
- Fonts: Settings → Appearance → Font (Classic, Modern, Rounded, Serif) and Arabic font (Amiri Quran, Scheherazade New, Noto Naskh Arabic), with a preview.
- Play readiness: release builds sign with the upload key from `android/key.properties` or CI secrets; CI builds the Play bundle when the key exists; RELEASE.md (human steps, Data safety and permission answers) and a store listing draft. Version 0.3.0+3.
- Code: settings split into one file per section; shared widgets for menus, tiles, Arabic blocks and settings controls.
- Calmer Today: ayah, hadith and quote now share one card with tabs; the prayer card shows only the next prayer (all times stay on the Prayer screen); the activity list and journal banner became two small tiles; the weather chip is one line shorter.
- Tafsir: open the ayah to read published tafsir for it, Al-Muyassar (Arabic) and Al-Mukhtasar (English), bundled verbatim for all 120 daily ayahs. Hadith cards say plainly that no reviewed explanation is available yet.
- Show another: the ↻ button on the content card shows the next ayah, hadith or quote for today.
- Settings moved out of More into their own menu, opened from the gear on Today, with one page per section.
- Four more colour themes: Emerald, Rose, Dusk and Slate.
- Backup: Settings → Backup exports habits, habit checks, moods, activities, journal and settings to a JSON file you choose, and imports it again. Merge keeps what is on the phone (habits matched by name, newer mood or journal of a day wins, duplicates skipped); Replace restores the backup exactly. Files from other apps or newer versions are rejected without changing anything.
- Animations: habit checks pop in, streak and count changes fade, Today says "All done today" when every habit is checked, ayah/hadith/quote cards open and close smoothly, tabs fade in. All are off when Android's "Remove animations" is on.
- Colour themes: Settings → Appearance → Sage, Ocean, Desert or Night (true black, always dark). Provisional until designed.
- Journal lock: Settings → Privacy → Lock journal. The Journal tab, Today's journal shortcut and the Calendar day hide journal text until unlocked with the phone's fingerprint, face or screen lock; it locks again whenever Nurday leaves the screen. Android: MainActivity is now a FlutterFragmentActivity with an AppCompat launch theme, and the app declares USE_BIOMETRIC.
- Google Drive backup: Settings → Backup → Connect Google Drive saves the same backup file to Nurday's hidden app folder in the user's own Drive (scope `drive.appdata` only), then once a day automatically; Back up now, Restore (merge or replace) and Disconnect. No Nurday server or account. Needs a Google Cloud OAuth client before it works (README).

## 0.2.0 (unreleased)
- Hadith shown in Arabic (verbatim from the same dataset) above the English; Settings → Content language: Arabic + English or Arabic only.
- Dark theme (provisional tokens until designed); Settings → Appearance: System, Light, Dark.
- Prayer times calculated on the phone: next-prayer card on Today, Prayer times screen with Qibla bearing, 12 calculation methods, Standard or Hanafi Asr, optional prayer notifications.
- Hijri date (Umm al-Qura) on Today.
- Quotes are now Arabic only: 55 sayings from the OpenITI corpus (al-Shafi'i, al-Mutanabbi, Ibn al-Jawzi). The English quote list is removed.
- High latitude rule setting; prayer times tested against adhan's reference tables (Makkah, London, a full New York year across DST).

## 0.1.0 (unreleased)
- Phases 1–3: app shell, theme from the design, Drift database, Today, Habits, Calendar, Journal, Activities, Reflect, Settings.
- Daily ayah from AlQuran Cloud / Quran.com with cache and offline fallback; bundled Bukhari subset and quotes.
- Weather from Open-Meteo by city or location.
- Phase 4: daily reminder (on/off + time) and per-habit reminders as local notifications, rescheduled after reboot; launcher and adaptive icon plus splash in the Nurday palette; accessibility pass (every tab works at 200% text size, labelled controls).
- Tests: dates, streaks, database rules, content parsing and offline fallback, no scripture in app code, end-to-end widget flows.
