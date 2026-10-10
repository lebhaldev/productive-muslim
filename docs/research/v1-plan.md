# V1 plan from the research agents (2026-10-07)

Lead strategist synthesis of [benchmark](benchmark.md), [audience](audience.md) and [brainstorm](brainstorm.md). Owner decides what to keep.

## Verdict

Nurday is in a gap that no competitor owns: a private, calm, Muslim-centred companion for the inner life (journal, mood, reflection) that is also built around the day's worship, with every religious word cited. Pillars and Mawaqit match it on privacy, but they are prayer-time tools. Muslim Pro and Athan have the breadth, but users distrust them over ads and the 2020-2022 data scandals. Daylio and Stoic own mood and journalling but have no faith layer. Two prayer-time basics are weak today. Prayer notifications use inexact alarms (lib/data/reminders.dart uses inexactAllowWhileIdle), and there is no Hijri offset (prayer.dart has a fixed Umm al-Qura label). These are the reasons users uninstall prayer apps, so they must be fixed before launch. The winning move is not to match Muslim Pro feature for feature. Ship a small, reliable V1 that does "prayer + habits + journal" without guilt, and say loudly that there are no ads, no account, no data collected and no AI-written religious text.

**Positioning:** Your calm, private daily companion: prayer times, gentle habits and a locked journal, with every verse and hadith cited. No ads, no account, nothing leaves your phone.

## Must before V1

- **Reliable prayer notifications** (M) — Switch prayer alerts to exact alarms (USE_EXACT_ALARM, or SCHEDULE_EXACT_ALARM with a fallback). Re-schedule on boot, timezone change and app update. Add a 'Test notification' button and a guided screen for battery optimisation, with notes for Samsung, Xiaomi and Huawei. Today reminders.dart uses inexactAllowWhileIdle.  
  *Why:* Missed or late adhan alerts are a top complaint for Athan, Mawaqit and Muslim Pro (an analysis of 995 Muslim Pro Play reviews), and Quran Majeed's developer publishes a page on fixing them. One missed Fajr leads to a 1-star review.  
  *Risk:* Play restricts USE_EXACT_ALARM to alarm and calendar apps. A prayer-time alarm app should qualify, but write the policy declaration carefully and fall back to SCHEDULE_EXACT_ALARM plus a user permission prompt. Follow the nurday-play-release skill.
- **Hijri date offset (±2 days)** (S) — A setting that shifts the displayed Hijri date by -2 to +2 days, applied everywhere hijriLabel is used, so later Ramadan and special-day features inherit it.  
  *Why:* Users see one-day mismatches between countries (the hijri_date GitHub issue, complaints about Mawaqit). It is a cheap fix, and Ramadan mode and special days depend on it.  
  *Risk:* none
- **Per-prayer minute adjustments** (S) — A ±30 minute offset for each of the five prayers (plus sunrise) in prayer settings, so times match the local mosque.  
  *Why:* 'Times don't match my mosque' is a common complaint across the category. Salam offers manual corrections, and Mawaqit's whole model exists because of this problem.  
  *Risk:* none
- **Prayer log as part of habits** (M) — Five prayer check-offs per day, reachable by tapping the next-prayer card, shown as dots on the calendar and counted in Reflect. Each prayer is a plain done or not-done mark. There are no late or congregation states in V1.  
  *Why:* Pillars, Athan, Salam, Deen Tracker and Daily Deeds all have a prayer log, and it is the most requested missing piece for a 'daily companion'. Nurday's calendar and Reflect screens are already built to show it.  
  *Risk:* Guilt. Use soft colours, never show red 'missed' marks or lost-streak pop-ups, and include the excused-day option below.
- **Gentle consistency and excused days** (S) — Replace streaks that reset to zero with 'X of the last 7 days'. Add a private 'excused' day (illness, travel, menstruation) that never counts against habits or prayers, and a setting to hide streak numbers completely. Never show nagging or lost-streak notifications.  
  *Why:* On the GTAF board, users say they protect the streak instead of worshipping and ask for a way to hide it. Al-Adhan, Niya and Nisa Care advertise a menstruation pause. This is Nurday's emotional differentiator and it is cheap to build.  
  *Risk:* Do not store a reason by default. Use one neutral 'excused' flag so that no sensitive health data sits on the device unless the user writes it themselves.
- **Location without GPS and auto-suggested calculation method** (M) — A first-run step that lets the user pick a city manually or use coarse location once. It suggests a calculation method and Asr school based on country (for example Umm al-Qura for Saudi Arabia, ISNA for North America, Diyanet-like for Turkey if available). Make it skippable.  
  *Why:* If prayer times are wrong on day one, people uninstall. Comparitech found about 40% of Muslim apps request location. Offering a choice with no GPS is a visible trust signal.  
  *Risk:* Offline city search needs a bundled city list. Keep it small, for example the top 2-5k cities, to protect app size.
- **Accessibility pass** (M) — Add TalkBack labels to every interactive control (only 17 Semantics wrappers exist today). Check text scaling up to 200% and contrast on all 9 themes. Add an Arabic text size slider that is separate from the UI text size.  
  *Why:* Blind Muslims report that almost no Islamic apps are accessible (AppleVis threads), and no TalkBack-tested Muslim app was found. Accessibility also counts toward Play quality, and the Arabic size slider helps older users.  
  *Risk:* none

## Polish before V1

- **Trust-first store listing** (S) — Title along the lines of 'Nurday: Prayer, Habits, Journal' (30 characters or fewer). Put 'prayer times' and 'Qibla' in the short description. The first screenshot should say 'No ads. No account. Your data stays on your phone.' Follow with screenshots in this order: Today, Ayah with source, Habits/Prayer, Locked journal, Calendar/Reflect, Themes. Cover spelling variants in the description (Adhan/Azan, Salah/Namaz, Qibla/Qiblah).  
  *Why:* Pillars got its press coverage entirely from privacy. 'Free, no ads, doesn't sell data' is the stock phrase people use when recommending alternatives.  
  *Risk:* Play metadata policy: no emojis, no 'best' or '#1', no keyword stuffing.
- **Honest Data safety form and fewer permissions** (S) — Declare 'No data collected / no data shared'. Confirm that Google Drive backup to the user's own app folder qualifies under Play's definitions. Explain each permission in the app at the moment it is requested. Audit dependencies for any SDK that phones home. Check what the weather call sends: coarse coordinates only, and named in the privacy policy.  
  *Why:* Users compare Data safety labels. The 2022 Measurement Systems SDK incident got prayer apps pulled from Play.  
  *Risk:* The weather request leaves the device with coordinates. Disclose it, round the coordinates, and let users turn weather off.
- **In-app Sources and principles screen** (S) — One screen that lists every edition used: the Quran text, Saheeh International and Clear Quran, Al-Muyassar and Al-Mukhtasar, the Bukhari and Muslim editions, and the quote sources. Show licences and the statement 'Nurday never generates or paraphrases religious text'. Link to it from every content card.  
  *Why:* Egypt's Dar al-Ifta has ruled AI-based tafsir impermissible, and some competitors market AI guidance. Visible provenance is a real differentiator and is cheap to build.  
  *Risk:* Licence check for each source. Follow the nurday-content-sourcing skill.
- **Backup status and auto-backup** (S) — Show 'Last backup: date' in settings and on the journal. Add an optional weekly automatic Drive backup and a reminder if no backup has run for 30 days.  
  *Why:* Data loss and paywalled backups make Finch and Daylio users angry. Free, visible backup is a strength Nurday already has, so show it.  
  *Risk:* none
- **No-repeat content rotation** (S) — Do not repeat an ayah, hadith or quote until the whole pool has been shown. Keep the rotation per user and deterministic.  
  *Why:* With only 120 items, repeats appear within a few months and make the app feel small.  
  *Risk:* none
- **Cold start and offline behaviour** (S) — Open to Today in under about 1 second. Lazy-load tafsir. When offline, hide the weather chip quietly. Prayer times must never depend on the network.  
  *Why:* Users with poor connectivity matter, and Play vitals are visible to reviewers. Speed is part of 'calm'.  
  *Risk:* none
- **Closed testing track and community seeding** (S) — Run Play closed testing with 12 or more testers for 14 days (a Play requirement for new personal accounts). Recruit through mosque and university Islamic society groups, and collect early honest reviews at the public launch.  
  *Why:* Pillars launched with community support. Early ratings decide whether the app ranks at all in a crowded category.  
  *Risk:* Never ask for reviews in exchange for anything, and never prompt for a review right after a prayer.

## After V1

- **Home-screen widgets** (M) — Start with a next-prayer widget (countdown and today's times, themed), then an ayah-of-the-day widget. Build with home_widget.  
  *Why:* Widgets are the most common gap against leaders (Pillars, Athan, Muslim Pro, Daylio) and are requested on public feedback boards. They drive daily use without notifications.  
  *Risk:* Countdown widgets show stale or '00:00' times (MasjidBox bug). Show the next prayer time rather than a ticking countdown, or use a Chronometer view. This is in v1.1 rather than V1 only because exact alarms and correct times come first.
- **Ramadan mode (target: Ramadan 1448, about February 2027)** (L) — Switches on from the Hijri date with the user's offset. Today shows suhoor and iftar countdowns, the calendar gets a fast log (fasted, excused, to make up), Quran progress feeds the khatm, and odd nights are marked in the last ten.  
  *Why:* Ramadan is the biggest acquisition moment of the year: Dulook DXB saw +185% on day 1, and Muslim Pro installs rose from 10-15k to 100k a day in 2014.  
  *Risk:* Any dua must be verbatim with a reference, through the content-sourcing skill. Ship the update and new screenshots by mid-January 2027.
- **Quran reading tracker (no reader)** (S) — Log pages, juz or surah read against the 604-page Madani mushaf. Show khatm progress and a 'finish by' pace calculator, with an optional deep link to Quran.com.  
  *Why:* Users get most of the value of a Quran goal (Quran.com's Growth Journey) with no mushaf to bundle and no content risk. It is also the main feature of Ramadan mode.  
  *Risk:* none
- **Count-based habits and tasbih** (M) — Add count habits (for example 100 dhikr) and a full-screen tasbih counter with haptics every 33. Its total feeds the matching habit.  
  *Why:* People use dhikr counters daily (Hisn al-Muslim, Salam, Azkar apps). This extends the habits system instead of adding a separate section.  
  *Risk:* Preset phrases must be verbatim Arabic. Do not show virtue text without a cited hadith.
- **Fast make-up and qada ledger** (S) — A private counter for fasts owed and made up, filled automatically from Ramadan 'excused' days, plus an optional prayer qada counter. Label it 'a tracking aid, not a fatwa'.  
  *Why:* Pillars and the Ramadan checklist apps have it, and reverts and returning Muslims need it. It is local and private.  
  *Risk:* Do not compute rulings such as hayd or istihada. The user enters the numbers.
- **Arabic UI with RTL** (M) — Translate the UI strings into Arabic, mirror the layout, and choose the language independently of the system language.  
  *Why:* The content is already Arabic, and Arabic speakers are a core audience. Few calm apps are properly RTL.  
  *Risk:* Translate only the UI. Religious content stays verbatim.
- **Morning and evening adhkar (Hisn al-Muslim)** (M) — A morning and evening adhkar screen with Arabic text, counters and references, plus a published translation only once its licence is confirmed. It can also appear as the evening card.  
  *Why:* This is the most-used daily ritual in Muslim daily apps and the biggest 'companion' gap against Hisn al-Muslim and Salam.  
  *Risk:* High sourcing risk: the English translation's licence is unclear. Ship Arabic plus references first if necessary, and gate everything through nurday-content-sourcing.
- **Weekly private review** (S) — One Friday card summarising habits kept, prayers logged, average mood and journal days, with a prompt to write a note to next week. Also add simple on-device observations ('mood is higher on days you journal').  
  *Why:* This combines Daylio's insights with Stoic's reflection. No Muslim app ties worship and inner life together, which is Nurday's core positioning.  
  *Risk:* Phrase findings as observations, never as religious claims.
- **Ayah and hadith share card** (S) — Render the current ayah or hadith as a themed image with the Arabic, the translation and the full reference always included, then open the Android share sheet. An optional small watermark.  
  *Why:* It is the only growth engine compatible with no ads and no analytics, and WhatsApp status sharing is common.  
  *Risk:* The text must not be editable and the reference cannot be removed. Include no personal data.
- **Optional one-time support (Play Billing)** (S) — One quiet 'Support Nurday' entry in Settings with 2-3 one-time amounts, a thank-you, and no unlocks.  
  *Why:* It keeps a free solo app sustainable, and users strongly dislike paywalls on religious apps (Tarteel and Muslim Pro reviews).  
  *Risk:* It adds Play Billing, so update the Data safety form and do not put the entry in the main flow.

## Later

- **Visual Qibla compass** (M) — A magnetometer compass with a calibration hint, an alignment haptic and an accuracy disclaimer, replacing the text bearing.  
  *Why:* Users expect one (Pillars, Salam, Mawaqit), but most people already have one installed, and phone sensors give bad readings that bring 1-star reviews. The value is moderate and the support burden is real.  
  *Risk:* Keep sensor data in memory only, and show the margin of error.
- **French, Indonesian, Turkish and Urdu UI** (M) — Translations by community volunteers using ARB files, with content translations added only where a licensed published source exists (for example Kemenag for Indonesian).  
  *Why:* These open the largest markets: Islamic app penetration in Ramadan was 9.8% in Malaysia and 7.2% in Indonesia (AppInsight 2019). Deen and Tarteel grew this way.  
  *Risk:* Each language needs a separately licensed source for its content translation. Maintenance load for a solo developer.
- **Special-day chips** (M) — A quiet chip on Jumu'ah (al-Kahf), Arafah, Ashura, the White Days, and Monday/Thursday fasts, each linking to a cited hadith.  
  *Why:* Timely, relevant and uncluttered, and it reuses the Hijri offset.  
  *Risk:* Every claim of virtue must quote a verbatim sahih reference. No paraphrase.
- **Per-prayer alert sounds** (M) — Silent, soft chime or short adhan per prayer, with a separate Fajr setting, and respect for Do Not Disturb.  
  *Why:* Adhan choice is the area Athan and Mawaqit lead in, but calm users often prefer a chime.  
  *Risk:* Audio must be public domain or self-recorded. App size.
- **Situational dua shelf** (M) — About 30 cited duas (travel, distress, home) with search.  
  *Why:* Useful in the moment it is needed, and it complements the adhkar.  
  *Risk:* Same licensing risk as the adhkar.
- **Hijri Year in Review** (M) — A local summary at Muharram where the user picks what goes into a shareable image.  
  *Why:* A seasonal moment people enjoy, with no server involved.  
  *Risk:* Avoid riya'. Keep it private by default and share only what the user explicitly includes.
- **Wear OS tile and app shortcuts** (L) — Launcher shortcuts (Journal, Log prayer, Tasbih) can come early. A watch tile for the next prayer and tasbih comes much later.  
  *Why:* Fast access is a delight and makes the app distinctive.  
  *Risk:* Maintenance burden on a second platform.
- **Serverless group khatm card** (S) — Generate an image or text card assigning juz to people, for sharing in a WhatsApp group. Nurday tracks nothing.  
  *Why:* Group khatms are a Ramadan tradition, and this needs no backend.  
  *Risk:* none

## Let go

- **Any AI explanation, chat or summary of religious content** — It breaks the hard rule, Dar al-Ifta has ruled against it, and refusing it is a selling point.
- **Leaderboards, public streaks, accountability buddies, family leaderboards** — Riya' concerns, they need a server or sharing of personal data, and they work against the calm, private positioning.
- **A built-in Quran reader or audio recitation** — Bloat is exactly why users leave Muslim Pro, Quran.com does this better, and it means a large content and licensing burden. Track reading and link out instead.
- **Family profiles on one device** — A large build for a niche need, it adds clutter and complexity to the data model, and it is hard to make private.
- **Pet or gamification mechanics, and 'come back' or lost-streak nudges** — Finch-style mechanics and re-engagement pop-ups are what users explicitly complain about, and they conflict with the calm design.
- **Ongoing next-prayer notification and travel-mode qasr toggle** — The ongoing notification is clutter and drains the battery, and the widget covers the same need. The qasr toggle touches fiqh for little value, and recalculating for a new city is enough.
- **Cosmetic supporter perks and a 'costs and roadmap' page** — Perks start splitting the app into free and paid tiers. A roadmap page is a promise a solo developer has to keep. A one-time tip is enough.
- **Year-stamped store titles ('Ramadan 2026')** — They go stale and add policy risk. Refresh the screenshots before Ramadan instead.

## Competitors

| App | Model | Strengths | Weaknesses |
|---|---|---|---|
| Muslim Pro | Freemium, ads, subscription | Very broad features, adhan audio, huge install base (about 113M Play downloads, per an aggregator) | Ads near worship, the 2020 X-Mode location-data scandal, bloat, unreliable alerts |
| Pillars | Free, no ads, no analytics | An identity built on privacy, minimalist design, widget, prayer tracker, fast make-up log; 4.8 on iOS | Focused on prayer times only: no journal, mood or daily content |
| Athan (IslamicFinder) | Free with ads, premium tier, donations | Many adhan voices, toggles per prayer, widgets | Heavy ads (loan ads), promotional notifications, alerts that fail silently |
| Mawaqit | Free waqf, no ads, collects no data | Real mosque iqamah times, muezzin choice, trusted | Missed notifications, no Hijri adjustment, tied to mosques |
| Quran.com | Free nonprofit, open source | The trust standard for sourced text, flexible reading goals and streaks | Quran only, now account-based sync, no daily-life layer |
| Hisn al-Muslim (certified) | Free | Adhkar endorsed by the book's author, 20 languages, counters | A single-purpose reference app with no tracking or reflection |
| Daylio | Subscription removes ads; backup partly paid | Two-tap mood log, Year in Pixels, correlations, PIN, Drive backup | No faith layer, backup behind a paywall, complaints about billing |
| Loop Habit Tracker | Free, open source (GPL) | Habit-strength score instead of strict streaks, flexible schedules, actionable notifications | Utilitarian design, no faith content |
| Deen Tracker / Daily Deeds / Niyyah | Small indie apps, local-first | Salah tracking without guilt, local data | Small reach, no content and no journal; no breakout winner in this niche |

## Audience insights

- Privacy is the defining trust issue in this category. Muslim Pro (2020), Salaat First (2021) and the SDK takedowns of 2022 made 'data never leaves your phone' the strongest signal an app can give. *(Al Jazeera, Vice, Tempo and Android Authority; BuzzFeed on the origin of Pillars)*
- Ads beside sacred content cause the most anger, and people recommend alternatives using the words 'free, no ads, no account'. *(Muslim Pro reviews on Trustpilot; AlternativeTo lists of alternatives; a usability study (BBG e-proceeding))*
- Unreliable prayer alerts are the top functional complaint, mostly caused by Android Doze and phone makers' battery savers. *(UIN Suska analysis of 995 Muslim Pro Play reviews; pakdata.com support page; unitQ scorecards for Athan and Mawaqit)*
- Opinion on streaks is split. Some users end up worshipping to protect the streak and ask to hide it, and lost-streak pop-ups are especially disliked. *(GTAF Quran app feedback board (via search summary))*
- Women need excused days (menstruation, postpartum) that never break streaks, and competitors now advertise this. *(Store listings for Al-Adhan, Niya and Nisa Care (developer listings))*
- Hijri dates differ by a day between countries, so users need a manual offset. *(hijri_date GitHub issue #8; Mawaqit complaints on unitQ)*
- Users are wary of AI-generated religious content. Egypt's Dar al-Ifta ruled AI tafsir impermissible in 2025, so 'never AI, always cited' is a marketable promise. *(Middle East AI News; USIM journal review)*
- Ramadan drives large usage spikes and is the main window for acquiring users. *(WAM: Dulook DXB +185% on day 1 of Ramadan 1447; 2014 Muslim Pro press release (self-reported))*
- Widgets for the next prayer and the Hijri date are requested repeatedly on public feedback boards. *(MasjidBox and Ishra feedback boards)*
- Accessibility is badly served. Blind Muslims say they cannot find accessible Islamic apps, and no app tested with TalkBack was found. *(AppleVis reviews and forum)*

## Open questions for the owner

- V1 date: are you willing to delay launch by about 3-4 weeks to ship exact alarms, the prayer log and excused days? Or launch sooner with only the reliability and offset fixes and put the prayer log in v1.0.1?
- Prayer log design: plain done or not-done only (recommended), or also on time, late and in congregation? The richer version adds more guilt and more user interface.
- Should the excused-day option say 'menstruation' explicitly (clearer for women) or stay a neutral 'excused' (more discreet)?
- Streaks: hide them by default and show 'X of the last 7 days', or show them by default with a hide toggle?
- Weather: keep it (it is the only network call that sends coordinates) or drop it so you can say 'works fully offline, zero network calls except backup'?
- Will you accept a one-time support purchase through Play Billing in v1.x, or keep the app completely free with no in-app purchases at all?
- Open source: would you publish the code (a credibility signal, as with Al-Azan and Quran.com), or keep it closed?
- Order for the first languages after Arabic: French (Maghreb and France) or Indonesian and Malay (the largest market)?
- Hisn al-Muslim English: are you comfortable shipping adhkar in Arabic with references only until a licensed translation is secured?
