# Changelog

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
