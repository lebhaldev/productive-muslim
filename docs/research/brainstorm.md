# NURDAY Brainstorm: ideas to make it better

Effort is for a solo Flutter developer: **S** is about 1 to 3 days, **M** is about 1 to 2 weeks, **L** is 3 weeks or more. A rule risk of "none" means it fits the hard rules as written.

## A. Core loop and retention without guilt

| # | Idea (one-line pitch) | Why users care | Effort | Rule risk |
|---|---|---|---|---|
| 1 | **Gentle streaks ("consistency, not perfection")**: show "5 of the last 7 days" in place of a streak that resets to 0. Add an optional "excused day" for illness, travel or menstruation that keeps consistency intact. | Broken streaks cause shame, and people often quit the app after one. Women in particular need a way to pause prayer and fasting tracking that does not count against them. | S | None. Keep the wording neutral and the excusal private. |
| 2 | **"Come back" screen with no guilt**: after 3 or more days away, open on one soft line and a single "start today" action. Never show "you missed X days". | It removes the shame that stops people from reopening the app. | S | The copy must not be religious. If it quotes an ayah, use a sourced verbatim one, for example 39:53. |
| 3 | **Evening wind-down card**: after Isha, Today changes to "close your day". It asks for mood, a one-line journal entry, and which habits got done, then offers a sourced evening dhikr. | It gives the day a natural ritual and closes the loop without extra screens. | M | Content sourcing for the dhikr. |
| 4 | **Intention of the day (niyyah line)**: an optional short user-written intention each morning, shown faintly on Today and in the journal. | It is personal, meaningful and very cheap to build. Users write it themselves, so it is not app-generated religious content. | S | None |
| 5 | **Weekly gentle review (on device)**: every Friday evening, one card shows habits kept, average mood and journal days, with a single prompt to write a note to next week. | It gives reflection without "analytics", and all the data is the user's own. | S–M | None. Everything is computed locally. |

## B. Special days and seasons

| # | Idea | Why users care | Effort | Rule risk |
|---|---|---|---|---|
| 6 | **Season mode (Ramadan)**: a Ramadan layout of Today with suhoor and iftar countdowns, fast tracker (fasted, excused or to make up), taraweeh check, khatm progress, and a sourced dua at iftar. Turns on automatically from the Hijri date, with a ±1 day adjustment. | Ramadan is the biggest acquisition and engagement moment of the year. Ramadan 1448 is around February 2027, so it is a natural target. | L | Content sourcing for the dua (verbatim, with reference). Hijri moon-sighting differences mean the user needs a manual offset. |
| 7 | **Qada fasts ledger**: count missed fasts and log make-up days. Usable all year. | It is a real, unmet need that is private and fits local-first. | S | Privacy. Keep it local and under the journal lock if enabled. |
| 8 | **Special-day banners**: a quiet chip on Jumu'ah (Surah al-Kahf reminder and sourced Friday sunnah), the first 10 days of Dhul Hijjah, Arafah, Ashura and Tasu'a, the White Days (13 to 15), and Mondays and Thursdays. | Timely, relevant nudges with no clutter, shown on the days they apply. | M | Each banner must cite a sahih hadith verbatim. The "virtue" text is a sourcing risk if paraphrased. |
| 9 | **Hijri date offset and moon-sighting setting**: ±2 day adjustment, plus a choice between Umm al-Qura and calculated. | Without it, every special-day feature is wrong for half the users. It is a prerequisite for #6 and #8. | S | None |
| 10 | **Last ten nights helper**: odd nights highlighted, an optional late-night reminder, and the verbatim Laylat al-Qadr dua (Tirmidhi 3513, with reference). | Very high emotional value for a short build. | S | Content sourcing |

## C. Prayer

| # | Idea | Why users care | Effort | Rule risk |
|---|---|---|---|---|
| 11 | **Prayer log (5 dots a day)**: tap the next-prayer card to mark a prayer as on time, late, in congregation or missed. The calendar month view shows the dots. | It is the most-requested feature in this category, and NURDAY already has the calendar. | M | Possible guilt. Keep the colours soft and offer "excused" (see #1). |
| 12 | **Qada prayer counter**: set an estimated backlog once, then tap to decrement, with a gentle progress ring. | Many converts and returning Muslims carry a large backlog and have no good tool for it. | S | Privacy. Keep it local. |
| 13 | **Visual Qibla compass**: magnetometer compass with an alignment haptic and a calibration hint. It replaces the current text bearing. | Text bearings are not usable on their own, and users expect a compass. | M | Store sensor data only in memory. Show an accuracy disclaimer. |
| 14 | **Per-prayer adhan options**: choose silent, a soft chime or a short tone for each prayer. Fajr can have its own setting. Respect DND. | Notifications are core, and the per-prayer setting is the top complaint in competitor reviews. | M | Licensing on adhan audio. Use recordings that are public domain or that you recorded. |
| 15 | **Pre-prayer nudge**: "Asr in 15 min" as a quiet notification (optional). | It helps users pray on time, with less stress. | S | None |
| 16 | **Travel mode**: detects a new city by coarse location on open, proposes recalculating, and offers a qasr/jam' informational toggle. | Reliability while travelling builds trust. | S–M | Fiqh. Do not rule on qasr; just let the user toggle it. |

## D. Quran, dhikr, duas

| # | Idea | Why users care | Effort | Rule risk |
|---|---|---|---|---|
| 17 | **Quran reading tracker (no reader)**: log the juz, page or surah read. It shows a khatm progress bar and a "finish by date" pace calculator (for example, 4 pages after each prayer). | It gives most of the value of a Quran app with no mushaf to bundle, and lets the app work alongside Quran.com or a physical mushaf. | S–M | None. It contains no text, only page numbers (604-page Madani). |
| 18 | **Tasbih counter**: full-screen tap area, haptic on each 33, presets (SubhanAllah, Alhamdulillah, Allahu Akbar, Astaghfirullah), custom targets, and a daily total saved to history. | Users want it daily, and it is a natural "habit" type. | S | The preset text must be verbatim Arabic. Cite any virtue mentioned. |
| 19 | **Morning and evening adhkar (sourced)**: Hisn al-Muslim by Sa'id al-Qahtani, Arabic plus a published translation, with counters and the references printed. | It is the most-used feature in Muslim daily apps, and it fits the "calm companion" positioning. | M | **High sourcing risk.** It needs a verbatim, licensed translation (check Hisn al-Muslim translation rights). Follow the nurday-content-sourcing skill. |
| 20 | **Situational dua shelf**: about 30 duas (travel, distress, entering home, after wudu), each with a reference and a search box. | Duas are useful in the moment they are needed. | M | Same as #19. |
| 21 | **Habit types**: count-based (dhikr 100×), page-based (Quran 2 pages) and time-based habits, alongside the current yes/no type. Tasbih and Quran tracking feed them automatically. | It unifies the app: one habits system rather than separate silos. | M | None |
| 22 | **Bookmark and reflect on the ayah**: save today's ayah, attach a private note, and browse a "my ayahs" collection. | It turns passive content into a personal record. The notes are the user's own words. | S | None |

## E. Widgets, wearables, platform

| # | Idea | Why users care | Effort | Rule risk |
|---|---|---|---|---|
| 23 | **Home-screen widgets**: (a) next prayer with countdown, (b) ayah of the day, (c) today's habits with tap-to-check. Uses `home_widget`. | It is the most-requested feature for prayer apps on Android, and it drives daily retention without notifications. | M | Clutter. Keep 2 or 3 sizes, styled to match the theme. |
| 24 | **Lock-screen and ongoing notification for the next prayer** (optional, low priority) | It gives glanceable time with no unlock. | S | Battery and annoyance. Keep it off by default. |
| 25 | **Wear OS tile**: next prayer and a tasbih counter on the watch. | A tasbih on the wrist is a delight, and the feature is distinctive. | L | Maintenance burden. Leave it until after V1. |
| 26 | **Quick-settings tile and app shortcuts**: a long-press on the icon offers "Tasbih", "Log prayer" and "Journal". | It is fast access and nearly free to build. | S | None |

## F. Onboarding, accessibility, localization

| # | Idea | Why users care | Effort | Rule risk |
|---|---|---|---|---|
| 27 | **3-step onboarding**: location (or a city picker with no GPS), auto-suggested calculation method by country (MWL, ISNA, Umm al-Qura, Egyptian, and so on) and Asr school, then choosing 3 starter habits. Skippable. | Wrong prayer times on day 1 lead to an uninstall. Auto-suggesting the method fixes this. | M | Privacy. Keep location on device and explain that clearly. |
| 28 | **Arabic UI with full RTL** | Arabic speakers are a core audience, and the app's content is already Arabic. It is a big differentiator in "calm" apps. | M–L | Translating UI strings is fine. Religious content stays verbatim. |
| 29 | **French, Indonesian, Urdu and Turkish UI** (community-translated via ARB files on GitHub or Weblate) | It opens the largest Muslim markets (Indonesia, Pakistan, the Maghreb, Turkey). | M per language | The content translations (ayah and hadith) need published sources per language, for example Hamidullah for French and Kemenag for Indonesian. Check the licence for each one. |
| 30 | **Accessibility pass**: TalkBack labels, dynamic type up to 200%, contrast checked on all 9 themes, an Arabic font-size slider separate from the UI size, and reduce-motion support (which already exists). | It helps elderly users and Arabic readers with small text, and it matters for Play Store quality. | M | None |

## G. Sharing, reflections, family

| # | Idea | Why users care | Effort | Rule risk |
|---|---|---|---|---|
| 31 | **Share card for ayah or hadith**: renders a beautiful image (theme-matched, Arabic plus translation, with the reference **always** included) and opens the Android share sheet. It contains no personal data. | Free organic growth through WhatsApp statuses and Instagram stories, and users love sharing. | S–M | The reference must always be included and the text must not be edited. Add a tiny "NURDAY" watermark that can be toggled. |
| 32 | **Personal insights from the user's own data**: on-device correlations such as "Mood is higher on days you log Fajr on time" or "You journal most on Fridays". | Insights about yourself are delightful, and no server is involved. | M | It must not make religious claims. Phrase findings as observations, not rulings. |
| 33 | **Year in review (Hijri year end)**: a local, shareable summary (khatms, prayer consistency, journal days), where the user picks what to include. | It is a "Spotify Wrapped" moment at Muharram. | M | Privacy. The user explicitly chooses every item that goes into a share image. |
| 34 | **Family profiles on one device**: switch between profiles for kids' habits and prayers, with child-friendly stickers. | Parents want to build habits with their children, and no account is needed. | L | Clutter. Hide it behind a setting. |
| 35 | **Peer-to-peer "accountability buddy" without a server**: exchange a weekly status card (QR code or shared image) with a friend, so nothing goes through a NURDAY backend. | Community without a server, done privately. | M | Privacy. It must be opt-in and only send what the user chooses. |
| 36 | **Group khatm via shared link (serverless)**: generate a juz-assignment card (for example, "Juz 1–30: Ali, Sara…") as an image or text for a WhatsApp group. NURDAY does not track it. | Group khatms are a huge Ramadan tradition, and the feature works without any backend. | S | None |

## H. Offline, performance, delight

| # | Idea | Why users care | Effort | Rule risk |
|---|---|---|---|---|
| 37 | **Offline guarantee and a "Works offline" badge**: weather degrades gracefully, prayer times are always on device, and the app shows a clear status. | Trust. Many users have poor connectivity. | S | None |
| 38 | **Micro-delight set**: soft haptic on habit check, a subtle light bloom on completing all habits, an optional soft tick sound, and a crescent animation on Hijri month change. All respect "remove animations". | Calm delight makes the app feel premium and is what people mention in reviews. | S–M | Clutter. Keep each one subtle and allow all of them to be turned off. |
| 39 | **Cold-start budget**: under 1 s to Today, lazy-load the tafsir, and pre-compute the prayer times for the day. | Speed is a feature, and it shows in Play vitals. | S–M | None |
| 40 | **Larger content pool with a no-repeat rotation**: no repeat until all 120 have been seen, with an optional "theme of the week" (patience, gratitude). | It keeps the content fresh. | S (rotation), M (themes) | Themes must come from source-tagged categories, not AI classification. |

## I. Monetisation (free, no ads)

| # | Idea | Why users care | Effort | Rule risk |
|---|---|---|---|---|
| 41 | **Sadaqah-style support**: a one-time "Support NURDAY" through Google Play Billing (3 tiers), with a thank-you and no unlocks. | It keeps the app free and fits Islamic giving culture. | S–M | Play policy requires in-app purchases through Billing, not external links. Data safety: purchases go through Google Play. |
| 42 | **Optional supporter perks (cosmetic only)**: extra themes, alternate app icons and share-card styles for supporters. Core features stay free forever. | It gives supporters a reason to pay without creating a paywall. | M | Users dislike paywalls on religious content. Never paywall the content. |
| 43 | **Transparent "costs and roadmap" page**: one screen showing what donations fund and what is coming next. | Builds trust, and the community feels ownership. | S | None |

---

## My personal top 10

1. **#11 Prayer log (5 dots) and #12 Qada counter.** These are the biggest missing piece for a "daily companion", and the calendar and Reflect screens are already built to show them. Effort M.
2. **#23 Home-screen widgets (next prayer and ayah).** This gives the most retention for the effort on Android. Effort M.
3. **#18 Tasbih counter and #21 count-based habits.** Users need it daily, it feeds the habits system, and it is quick to build. Effort S–M.
4. **#17 Quran khatm tracker (no reader).** It is high value, has zero content risk and is a natural Ramadan anchor. Effort S–M.
5. **#1 and #2 Gentle consistency with an "excused day".** This is NURDAY's emotional differentiator: calm instead of guilt. Effort S.
6. **#27 Onboarding with auto-suggested calculation method and #9 Hijri offset.** Prayer times that are right on day 1 decide whether people keep the app. These are prerequisites for V1. Effort M.
7. **#31 Privacy-safe share cards.** This is the only growth engine that respects "no ads, no analytics". Effort S–M.
8. **#6 Ramadan season mode** (including #7 qada fasts and #10 last ten nights). Build it for Ramadan 1448 (around February 2027), so it should be a V1.1 target in about 3 months. Effort L.
9. **#28 Arabic UI with RTL** as the first locale, with **#29** French and Indonesian next. It reaches the core audience and opens the biggest markets. Effort M–L.
10. **#41 One-time support through Play Billing.** This keeps the app sustainable without ads. Keep it to one quiet entry in Settings. Effort S–M.

**Suggested V1 cut (before Play Store):** #9, #27, #1, #11, #18, #23 (next-prayer widget only), #37 and #39. Ship them, then aim V1.1 at Ramadan with #6, #17 and #31.

**Highest rule-risk items to gate through the content-sourcing skill:** #8, #10, #19 and #20, plus the content translations in #29. Each needs a named, licensed, verbatim source before any text ships.