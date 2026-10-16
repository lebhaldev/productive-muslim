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
| B1 | Mood check-in that answers back with one small next step | Adapt | After a mood is picked, Today shows one calm line and one suggestion (write a gratitude note, open the journal, a habit not done yet). Lines are fixed app copy written once and reviewed, never generated, never religious claims. "Not now" hides it for the day. |
| B2 | Ayah matched to mood | Adapt, later | Only through human tags on the existing 120-ayah pool (e.g. `hope`, `patience`, `gratitude`) checked by the reviewer. No tags, no matching. The daily pick stays the default. |
| B3 | Prayer arc with done ticks | Take | Already planned as the prayer log (v1-plan "Must"). The arc becomes the visual of the next-prayer card and the Prayer screen: sunrise to sunset, five points, done ones filled sage. Tapping a point logs that prayer. Qibla shortcut on the card. Countdown in minutes, no seconds. |
| B4 | Prayer list states | Take | Prayer screen rows show `Done`, `Next · in 1 h 12 min`, or nothing. Never "Missed" in red. |
| B5 | Day progress bar | Adapt | One line under the habits header: `5 of 7 today` with a thin segmented bar (habits + logged prayers). No points. |
| B6 | Starter habits and habit rotation | Adapt | First run offers 6 suggested habits to tick (Read Qur'an, Morning adhkar, Evening adhkar, Gratitude note, Call family, Walk). Rotation is left out: it adds rules for little value. |
| B7 | Consistency with the "small regular deeds" hadith | Take | Habits header shows `X of the last 7 days` (already in the v1 plan) and, once, the hadith `bukhari:6465` from the bundled dataset, verbatim with its reference. |
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
- Store text and screenshots never name or compare to Balum.

## 4. Meeting notes

Pending: the builder and reviewer answers are added here when they arrive.
