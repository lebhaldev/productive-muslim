# Balum review: what Nurday takes, adapts and leaves (2026-10-16)

Input: 7 store screenshots of Balum (`app.balum`, Google Play) shared by the owner on 2026-10-16. The Play page itself is not reachable from the cloud container, so everything below comes from the screenshots. Balum is the closest app to Nurday seen so far: one app for prayer, mood, habits, reflection and learning, with a calm tone.

Reviewed by the spec thread (proposal), the builder thread (cost and fit with the code) and the reviewer thread (content rules and Play policy). Their notes are folded in under "Meeting notes".

## 1. What Balum does (from the screenshots)

| Area | What the screenshots show |
|---|---|
| Today | Mood check-in first ("How is your heart today?", 5 faces). After picking, a short line answers the mood ("You're feeling Grateful. Let's hold on to that") and offers one small action ("A moment of gratitude"), with "Change how I feel" and "That's all for now". |
| Prayer | A sun-path arc from sunrise to sunset with the five prayers on it, done prayers ticked, next one ringed, countdown, Qibla button. Prayer screen: city picker, list with "Passed" and "Up next" states. |
| Day progress | "13 / 17 done today" segmented bar on Today, plus guided-lesson progress. |
| Habits | Checklist with a starter set (Read Qur'an, Gratitude journal, Smile at five people, Read Surah Al-Mulk). A consistency count next to the Bukhari hadith on small regular deeds. "Add habit" and "Manage habits" (fixed anchors + a rotating set). |
| Mood week | A 7-day strip of the week's moods (M … S). |
| Reflections | Journal prompt "What's on your heart today?" + "Start writing". |
| Dua journal | "Your sky": every dua the user makes is a star; each is marked answered or still waiting ("3 answered, 2 held in trust"). |
| You | Weekly sentence ("This week, your heart leaned toward gratitude"), a moon that fills as the day's habits are done ("7 of 7 tended"), streak and tasks chips, a dismissible "shape your habits" card. |
| Learn | Levels and points ("Level 9, 2,450 / 3,500 light"), learning paths (Five Pillars), "Knowledge of the day" ayah matched to the mood, library (Quran 114 surahs, Hadith 6 collections, stories, history). |
| Daily Peace | A 10-step guided session (ayah, then an app-written "Context" paragraph), points and a 7-day streak, share and bookmark. |
| Shell | Tabs Learn, Prayer, Today, You, More. EN/AR switch in the header, notification bell. Arabic listing uses a light pastel look (one tint per tab); the English listing uses navy and gold with stars and a moon. |
| Store | Screenshots with a two-line headline and one short subline per frame. |

## 2. Decisions

**Take** = fits Nurday as is. **Adapt** = the idea fits, but Nurday does it its own way. **Leave** = conflicts with Nurday's rules or positioning.

| # | Balum idea | Call | Nurday version |
|---|---|---|---|
| B1 | Mood check-in that answers back with one small next step | Adapt | After a mood is picked, Today shows one calm line and one suggestion (write a gratitude note, open the journal, a habit not done yet). Lines are fixed app copy written once and reviewed, never generated, with no religious promises and no mental-health advice (Play Health declaration is "no health features"). Rough and low moods get a neutral action only. "Not now" hides it for the day. |
| B2 | Ayah matched to mood | Adapt, later | Only through tags set by a person (the owner or someone knowledgeable), never by an agent, on the existing 120-ayah pool (e.g. `hope`, `patience`, `gratitude`). The reviewer checks format and that each tag maps to a real ref. The card stays "Ayah of the day" and never shows the tag. No tags, no matching. |
| B3 | Prayer arc with done ticks | Take | Already planned as the prayer log (v1-plan "Must"). The arc becomes the visual of the next-prayer card and the Prayer screen: sunrise to sunset, five points, done ones filled sage. Tapping a point logs that prayer. Qibla shortcut on the card. Countdown in minutes, no seconds. |
| B4 | Prayer list states | Take | Prayer screen rows show `Done`, `Next · in 1 h 12 min`, or nothing. Never "Missed" in red. |
| B5 | Day progress bar | Adapt | One line under the habits header: `5 of 7 today` with a thin segmented bar (habits + logged prayers). No points. |
| B6 | Starter habits and habit rotation | Adapt | First run offers 6 suggested habits to tick (Read Qur'an, Morning adhkar, Evening adhkar, Gratitude note, Call family, Walk). Rotation is left out: it adds rules for little value. |
| B7 | Consistency with the "small regular deeds" hadith | Take | Habits header shows `X of the last 7 days` (already in the v1 plan) and, once, the hadith `bukhari:6465` from the bundled dataset: full Arabic and English text as in the dataset with its reference, and no app sentence linking it to the user's numbers. |
| B8 | Mood week strip | Take | A 7-day mood strip on Reflect and under the mood picker on Today (tap a day opens it in Calendar). |
| B9 | Journal prompt | Adapt | The journal placeholder rotates through a short fixed list of neutral prompts (`What are you grateful for today?`, `What went well?`, `What weighed on you?`). |
| B10 | Gratitude moment | Adapt | A "Gratitude" block in the Journal: three short lines, saved with the day's entry, shown on the Calendar day. Counts as a journal entry. |
| B11 | Dua journal with answered / waiting | Adapt (new feature) | **Duas**: a private list of the user's own duas. Each has text, date, optional note, and a state `Asking` or `Answered` (date answered). Lives under More, hidden by the journal lock. Visual must be Nurday's own (sage/terracotta, leaves or plain list), never stars, sky, moon or gold. No Quran or hadith text is added to it by the app. |
| B12 | Weekly sentence | Adapt | Friday card on Reflect from the v1 plan's "Weekly private review": plain counts (`Mood was mostly good`, `Journal 4 of 7 days`), no religious wording, no "your heart leaned". |
| B13 | Moon that fills with habits | Leave | Too close to Balum's identity. Nurday keeps its sage check and progress bar. |
| B14 | Levels, points, "light", streak flames | Leave | Already in "Let go": gamifying worship and riya'. |
| B15 | Guided sessions with app-written "Context" | Leave | Breaks CR-4: Nurday never writes explanations of scripture. Nurday's ayah card already shows published tafsir verbatim. |
| B16 | Lessons, stories, Islamic history library | Leave for now | Needs a licensed, reviewed source per text. Revisit only with a named source. |
| B17 | Library links (Quran, hadith collections) | Later | A "Sources" list linking out to Quran.com and sunnah.com fits the "link out, no reader" rule. Low priority. |
| B18 | EN/AR switch | Take, earlier | Arabic UI with RTL moves from "After V1" up to v1.1, first after the prayer log: Balum shows Arabic speakers are a primary audience. |
| B19 | Bookmark and share ayah | Take | Bookmark (local "Saved" list under More) and the share card already planned in "After V1". |
| B20 | Notification bell / inbox | Leave | No server, nothing to put there. |
| B21 | Headline-style store screenshots | Adapt | Re-caption Nurday's 8 store screenshots with a short headline and one subline each, in Nurday's own words and palette (list in design brief). |

## 3. Staying clear of a copycat

Play's impersonation and repetitive-content policies reject apps that look like a copy. Nurday must not reuse Balum's name, wording, illustrations or look.

- No navy + gold, no night sky, stars, constellations, moon-fill or lantern art. Nurday stays sage + terracotta with its light, warm base.
- None of these labels: "Your sky", "held in trust", "Daily Peace", "Your journey", "Make it yours", "tended", "light" as points, "Your heart", "A moment of gratitude", "More than a prayer app", "Faith. Reflection. Wellbeing.".
- Feature ideas are not protected, but each Nurday screen keeps its own layout and copy, written from the Nurday spec, not from the screenshots.
- Store text, keywords and tags never name or compare to Balum.
- The icon and screenshot frame layouts are Nurday's own, not mirrors of Balum's frames.
- Nurday keeps its tab set (Today, Habits, Calendar, Journal, More), not Learn / Prayer / Today / You / More.

## 4. Meeting notes (2026-10-16)

**Builder** (checked against app-v0.1 at 9de1f8d, version 1.0.1+5):
- Shared blocker: the Drift schema is still version 1 with no migration code, and backup is format 1. The first new table brings a migration strategy, a migration test and backup format 2 (still reading format 1). Done once, with the prayer log.
- Costs: B1 S, B3/B4 M–L (arc is a CustomPainter; most cost is per-point accessibility), B5 S, B6 S, B7 S, B8 S, B10 M (a `gratitude` column on journals), B11 M, B18 L (no flutter_localizations or ARB yet, every string is a literal across about 25 files, RTL pass on every screen).
- Order: B5 right after the prayer log; B10 next to B11 so both share one backup bump; start Arabic string extraction early in parallel, because it touches every screen.
- No clashes with work in flight.

**Reviewer** (content rules and Play): no blockers.
- B1 fine as fixed copy: no religious promises, no mental-health advice; neutral action for rough and low moods.
- B2 only with tags set by a person, never an agent (tagging ayat by meaning is AI interpretation, CR-4). Tag never shown.
- B7 fine: show the full dataset text (EN + AR) with its reference, nothing tying it to the user's score.
- B9, B10, B12 fine. B11 fine with the user's own text only; any sample duas need a cited, licensed source (Hisn al-Muslim translations are copyrighted). Same for adhkar text behind the B6 habit names: names are fine, bundled text is not.
- B18: machine help for UI strings is fine, but a native speaker reviews them and the Arabic store listing before release.
- Play: section 3 is enough with the three lines added above. Data safety: once export or Drive backup includes duas and the prayer log, declare "Personal info → Religious or political beliefs: collected, optional, user-initiated, not shared, purpose backup", next to "Other user-generated content", and list duas and prayer log in PRIVACY.md.
- Agrees with every Leave; blocks no Take.

**Result:** proposal kept, with the changes above folded into section 2, section 3, 01 §7b and 04 Phase 6.
