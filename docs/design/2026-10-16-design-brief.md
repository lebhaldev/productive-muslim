# Message for the design agent (2026-10-16)

Paste everything below the line into Claude Design, in the Nurday project.

---

Hi, this is the Nurday build team. Nurday is live in Play internal testing. The owner looked at a similar app (Balum) and we agreed on a set of new screens and changes for v1.1. Please design them in Nurday's existing look: the Organic design system, sage + terracotta on the warm light base, Fraunces-style headings, pill rows, the 5-tab bar (Today, Habits, Calendar, Journal, More). Please also give each new screen a dark version using the provisional dark tokens.

**Hard rules for this pass**
- Do not use navy and gold, night skies, stars, constellations, a filling moon, lanterns, points, levels or flame streak icons. We must not look like Balum, or Play may treat Nurday as a copycat.
- Every Quran or hadith text in a mockup stays a placeholder box labelled "verbatim from source", with a reference line under it. Never write sample scripture.
- No red "missed" states anywhere. Not-done is just empty.
- Copy below is our wording; feel free to tighten it, but keep its meaning.

**1. Today: mood check-in that answers back**
After the user picks a mood in "How do you feel?", the mood card shows one calm line and one suggestion button under it, plus a small "Not now" link. Example for "good": "Glad to hear it." + button "Write one thing you're grateful for". For "low": "Thanks for noticing it." + button "Open today's journal". Five moods, one line and one suggestion each. Show the selected and the dismissed states.

**2. Today and Prayer screen: the prayer day line**
Replace the next-prayer card's plain row with a gentle arc from Fajr to Isha with the five prayers on it and sunrise and sunset marked. Logged prayers are filled sage dots, the next one has a ring, others are empty. Under the arc: "Asr · 15:58 · in 1 h 12 min" and a small "Qibla" button. Tapping a dot logs or unlogs that prayer (a short "Dhuhr logged" snackbar with Undo). On the Prayer screen, the list rows show "Done", "Next · in 1 h 12 min", or nothing.

**3. Habits: gentle consistency**
- Under the "Habits" heading: "5 of 7 today" and a thin segmented bar (one segment per habit and logged prayer).
- Each habit shows "5 of the last 7 days" instead of a streak count. A setting can hide these numbers.
- A one-time card at the top of Habits shows the hadith on small regular deeds (placeholder box, reference "Sahih al-Bukhari 6465") with a close button.
- An "Excused today" option (single neutral flag; the day doesn't count against habits or prayers). Show where it lives: a small link under the habits list on Today.

**4. Mood week strip**
Seven small mood dots (Mon to Sun) under the mood picker on Today and at the top of Reflect. Empty days are faint rings. Tapping a day opens it in Calendar.

**5. Journal: prompts and gratitude**
- The body placeholder changes daily from a short list: "What are you grateful for today?", "What went well?", "What weighed on you?".
- A "Gratitude" block above the body: three short numbered lines, each optional. The Calendar day detail shows them under Journal.

**6. Duas (new screen, under More)**
A private list of the user's own duas.
- More gets a row "Duas · Your own duas, private to this phone".
- Screen: input "Write a dua" + Add; two sections "Asking" and "Answered" with counts. Each row: text (2 lines), date added, a check button "Mark answered". Answered rows show "Answered 12 Oct". Long-press or a menu: Edit, Move back to Asking, Delete (confirm).
- Empty state: one short line, e.g. "Write the duas you are making. Only you see them."
- When the journal lock is on, this screen is locked the same way (lock icon, title, Unlock button).
- Visual idea in Nurday's language, not a sky: a quiet sage leaf or small plant mark that gains a leaf for each answered dua. Your call.

**7. First run**
Three short steps, all skippable: (1) location for prayer times and weather (search a city, or use location once), (2) pick starter habits from six chips: Read Qur'an, Morning adhkar, Evening adhkar, Gratitude note, Call family, Walk, (3) "Your data stays on this phone. No account, no ads."

**8. Weekly review card (Fridays, on Reflect)**
Plain counts: "Habits kept 5 of 7 days", "Prayers logged 28", "Mood mostly good", "Journal 4 of 7 days", and a button "Write a note to next week". No religious wording, no scores.

**9. Arabic UI**
Please show Today, Habits and Duas in Arabic, mirrored right to left, with a language switch in Settings → Appearance (System, English, العربية).

**10. Store screenshots**
New captions for our 8 store screenshots, two short lines each, in our palette: (1) "Your day, calmly. / Prayer, habits and journal in one place." (2) "Every verse cited. / Ayah, hadith and tafsir with sources." (3) "Small deeds, kept. / Gentle habits without guilt." (4) "See your month. / Mood, habits and journal by day." (5) "Write it down. / A private, lockable journal." (6) "Prayer times, on your phone. / Calculated offline, with Qibla." (7) "Your colours. / Twelve calm themes, light and dark." (8) "No ads. No account. / Your data stays on your phone."

When you're done, please export `Nurday.dc.html` and screenshots of every changed screen so the owner can drop them in the project.
