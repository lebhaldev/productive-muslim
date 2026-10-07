# Changelog

## 0.3.0 (unreleased)
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
