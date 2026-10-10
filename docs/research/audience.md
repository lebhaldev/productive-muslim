# NURDAY audience research: what practising Muslims want from a daily companion app

**How this was researched:** Reddit (reddit.com, including its JSON search) could not be fetched from this environment. Several primary sources were also blocked: comparitech.com, kimola.com, feedback.gtaf.org, oscar.org.uk, fiveprayer.app and grand-screen.com. Most of the evidence below therefore comes from search-engine summaries of news coverage, academic abstracts, public feedback boards, App Store listings and review aggregators. **A claim that comes only from a developer's own store listing describes what that app offers, not proof that users want it**, and it is labelled that way. Reddit opinion is represented only through GummySearch's Reddit aggregation. **Every sentiment below is paraphrased; none is a verbatim quote.** Anything I could not check is marked *unverified*.

---

## 1. Summary for the decision-maker

1. **Privacy is the trust issue that defines this category.**
   - Three documented scandals, in 2020, 2021 and 2022, involved Muslim prayer apps sending location data to brokers linked to US government or defence work.
   - Pillars, a well-known privacy-first app, was built as a direct reaction to the first of them.
   - NURDAY's rules (no account, no server, no analytics, data stays on the device) match the strongest trust signal in this market. **They should be the first thing the store listing says.**
2. **Ads in a religious context make people angry**, especially ads around the adhan or in front of the Quran. "Ad-free" and "free" are the two words most often used to recommend alternatives.
3. **Unreliable prayer notifications** are a top functional complaint. On Android this is mostly battery optimisation (Doze).
4. **Opinion on streaks is split.**
   - Some people find them motivating.
   - Others say they end up "protecting the streak" instead of worshipping, and they ask for streaks that can be hidden or turned off.
   - Pop-ups about lost streaks are particularly disliked.
   - Women need streaks that pause during menstruation. Competing apps now advertise this.
5. **AI-generated religious content is controversial.** In 2025 Egypt's Dar al-Ifta ruled that AI-based Quran interpretation is impermissible. NURDAY's verbatim-only rule matches what cautious users expect, and the app should say so publicly.
6. **Most requested features that NURDAY lacks:** home-screen widgets (next prayer, Hijri date), a Hijri date offset of ±1 or 2 days, Ramadan mode (suhoor and iftar times, fasting log, khatm plan), a qada (missed prayer) tracker, interface languages other than English, and accessibility labels for screen readers.

---

## 2. Top desires

| # | Desire | Evidence | Fit with NURDAY |
|---|---|---|---|
| 1 | **No ads, free, no account** | People recommending alternatives repeatedly lead with "ad-free / free / no account": Al-Adhan (App Store listing: "no ads, no fees, no subscriptions"), Al-Azan (AlternativeTo: "privacy-first ad-free open-source"), Vakti, Muslimeen. Sources: [AlternativeTo: Muslim Pro alternatives](https://alternativeto.net/software/muslim-pro--prayer-times-azan-quran-and-qibla), [Al-Adhan on the App Store](https://apps.apple.com/app/id6475015493), [AlternativeTo: Al-Azan](https://alternativeto.net/software/al-azan--prayer-times) | Already matches |
| 2 | **Data stays on the phone** | Pillars' policy says data "never leaves your phone" and prayer times are calculated on the device. Comparitech found no serious leaks in Pillars ([BuzzFeed News](https://www.buzzfeednews.com/article/ikrd/pillars-app), [Comparitech](https://comparitech.com/blog/vpn-privacy/muslim-prayer-app-study), seen via search summary). Pillars shows about 4.8★ from about 3.5K ratings on the App Store ([listing summary via mwm.ai](https://spark.mwm.ai/kr/apps/pillars-prayer-times-qibla/1559086853), *rating not checked directly*). | Already matches; say it louder |
| 3 | **Accurate, configurable prayer times and dependable alerts** | An academic analysis of 995 Muslim Pro Google Play reviews lists "frequent error-prone prayer alerts" among the main complaints ([UIN Suska repository](https://repository.uin-suska.ac.id/82270/), via search summary). Quran Majeed's developer runs a support page blaming missed adhan alerts on Android Doze and phone makers' battery savers ([pakdata.com](https://pakdata.com/fix_adhan_notification)). | Partly: calculation methods are covered; notification reliability needs work |
| 4 | **Home-screen widgets** (next prayer; all five times; Hijri date) | A feature request on MasjidBox's feedback board asks for small, wide and large widgets, arguing they keep the app visible and used ([feedback.masjidbox.com](https://feedback.masjidbox.com/p/app-widgets-availability)). An Ishra feedback-board request asks for a dhikr-counter widget ([ishra.userjot.com](https://ishra.userjot.com/)). | Missing |
| 5 | **Gentle, private habit tracking that doesn't guilt-trip** | Several newer apps market directly against guilt: Niyyah offers a "private streak … gentle rather than guilt-inducing"; in Daily Deeds, streaks carry on after breaks ([mwm.ai Niyyah](https://mwm.ai/apps/niyyah-salah-tracker/6781700285), [Daily Deeds](https://apps.apple.com/app/id6747918880)). These are developer listings, but their positioning shows where competitors think demand lies. | Largely matches; add a pause or "grace" option |
| 6 | **Menstruation and postpartum pause that doesn't break streaks** | Al-Adhan's listing has a "menstruation and postpartum pause" so exempt days never break a streak. Nisa Care, Niya, The Confident Muslim and the Salah Tracker on itsallwidgets have similar features ([Al-Adhan](https://apps.apple.com/app/id6475015493), [Niya](https://apps.apple.com/app/id1668179563), [itsallwidgets Salah Tracker](https://itsallwidgets.com/salah-tracker)). | Missing; important for women |
| 7 | **Ramadan support** (suhoor and iftar times or countdown, fasting log, khatm plan, daily reflection) | These features recur across Ramadan apps (developer listings: [Ramadan Companion](https://apps.apple.com/us/app/-/id6756682875), [My Ramadan](https://apps.apple.com/us/app/-/id6742317146), [GTAF list of Ramadan apps](https://cms-internal.gtaf.org/best-apps-for-ramadan-for-android-and-ios/)). Usage clearly spikes: Dubai's Dulook DXB app reported usage 185% above normal on the first day of Ramadan 1447 / 2026 ([WAM](https://www.wam.ae/en/article/1749dxv-dubai’s-dulook-dxb-prayer-app-nears-one-million)). In 2014 Muslim Pro said daily installs rose from about 10–15K to up to 100K in Ramadan ([Mynewsdesk press release](https://www.mynewsdesk.com/sg/preciouscommunications/pressreleases/the-big-10-for-muslim-pro-s-mobile-app-985872), self-reported). | Missing |
| 8 | **Qada (missed prayer) tracking** | Many small apps exist (Qadaa, made with the Muslim Board of Uzbekistan; Qaza Qada; Salah Journal; Tawba), most offline-only. **Review counts are small, so the size of demand is unverified** ([Qadaa via mwm.ai](https://mwm.ai/apps/qadaa/6450267788), [Qaza Qada](https://apps.apple.com/app/id6757791803)). Qaza Qada presents handling the menstruation exemption as a gap in most qada calculators. | Missing; candidate for after V1 |
| 9 | **Hijri date that matches local moon sighting** | Users see a one-day mismatch between countries. Example: a GitHub issue on the Flutter `hijri_date` library reports UAE and India differing by a day ([GitHub issue](https://github.com/ahmedoid/hijri_date/issues/8)). Mature tools offer a ±1–3 day offset ([moonsighting.org.uk](https://www.moonsighting.org.uk/moon/hijri-calendar-app.html), [GNOME extension review](https://extensions.gnome.org/review/50928)). | **Check whether NURDAY has an offset.** If it doesn't, this is a quick fix before V1. |
| 10 | **Translations that are easy to read** | GummySearch's aggregation of Reddit (190 comments across 14 subreddits) gives The Clear Quran 4.8/5 and Saheeh International 4.4/5. Clear Quran is called "easiest to understand"; Saheeh is called "most accurate" ([GummySearch](https://gummysearch.com/tools/best-products/quran-translation/)). | Already matches (both offered) |
| 11 | **Interface in the user's own language** | Tarteel supports 12 interface languages, including French, Bahasa Indonesia, Bahasa Melayu, Turkish and Urdu ([Tarteel support](https://support.tarteel.ai/en/articles/12041685-multi-language-support)). Deen recruited volunteers to translate into Turkish, French and Indonesian ([deen.frill.co](https://deen.frill.co/announcements)). MuslimMatch added languages after user feedback ([Adnkronos](https://www.adnkronos.com/fastest-growing-muslimmatchcom-app-now-available-in-9-languages-including-english-french-german-malay-and-spanish_7D70vdvulTmcH28gfXoCd5)). **I found no hard numbers on retention by language.** | Missing (English only) |
| 12 | **Spiritual journaling and mood tracking** | It's an emerging niche: Sakinly (mood tracker plus journal), Sirr (released 2026), and Muhasaba (nightly self-accounting after Isha), plus many paid printable journals ([Sakinly](https://apps.apple.com/app/id6758906653), [Sirr via mwm.ai](https://mwm.ai/apps/sirr/6756618294), [Muhasaba on Product Hunt](https://www.producthunt.com/products/islamic-journal-muhasaba/makers)). **There are no independent reviews yet, so demand is unverified**, but the number of paid journal templates suggests interest. | Strength: NURDAY already has journal, mood and Reflect |

---

## 3. Top frustrations

1. **Ads, especially ads near worship.**
   - On Trustpilot, Muslim Pro reviewers complain the app constantly pushes ads. One says a negative store review got a reply telling them to buy Pro; another calls the ads "horrible" and says they switched apps ([pl.trustpilot.com](https://pl.trustpilot.com/review/www.muslimpro.com), via search summary).
   - A January 2024 Play Store review summarised by an aggregator says the app had become roughly "80% ads, 20% useful" (*paraphrase of an aggregator snippet; the original was not seen directly*).
   - One comparison site says the objection is to ads *inside a religious app*, such as full-screen video before or after the adhan ([unstar.app](https://unstar.app/blog/muslim-pro-quran-majeed-athan-pillars-tarteel-quran-prayer-apps-ranked-2026)). That site has a commercial interest.
   - A usability comparison criticised Muslim Pro for "intrusive advertisements, complex navigation, and feature restrictions for non-premium users" ([BBG e-proceeding](https://eproceeding.bbg.ac.id/index.php/iconesth/article/view/296), via summary).
2. **Paywalls and subscription traps.**
   - Tarteel's Play Store reviewers say premium features are priced too high ([Kimola report](https://kimola.com/reports/unlock-insights-tarteel-quran-memorization-app-feedback-report-google-play-en-gb-156338), via summary).
   - One reviewer asks that the roughly $9.99/month price be stated upfront ([JustUseApp](https://justuseapp.com/en/app/1391009396/tarteel-recite-al-quran/reviews)).
   - Complaints about trials that are hard to cancel and about Muslim Pro's paywalls come from an AI-generated review summary, so they are *unverified* ([marlvel.ai](https://marlvel.ai/apps/com-bitsmedia-muslimpro/vs)).
3. **Prayer alerts that arrive late or not at all** (see desire #3). The academic Muslim Pro review analysis also names "accounts that are automatically logged out" and "increasingly problematic upgrades".
4. **Streak pressure and nagging.** From user feedback on the GTAF board (Quran app), via search summary; the board itself was blocked ([feedback.gtaf.org](https://feedback.gtaf.org/board/p/option-to-completely-disable-or-hide-the-streak-counter)):
   - one user felt psychological pressure and opened the app mainly to protect the streak rather than to read;
   - another found the streak helpful at first, then stopped caring;
   - others said, in effect, "streaks are fine, just no pop-ups", objected to repeated "regain your lost streak" pop-ups, and asked for an option to hide streaks or a separate stats page.
5. **Bloat and complicated navigation** in all-in-one apps ([BBG e-proceeding](https://eproceeding.bbg.ac.id/index.php/iconesth/article/view/296)). Small privacy-first apps are recommended partly *because* they are focused.
6. **Hijri date mismatches** with the local moon-sighting authority (see desire #9).
7. **Poor accessibility.**
   - On AppleVis, a reviewer found Sajda's Quran section "not entirely accessible" because few buttons are labelled ([AppleVis](https://www.applevis.com/apps/ios/lifestyle/sajda)).
   - A 2017 thread there said blind users couldn't find accessible Islamic apps ([AppleVis forum](https://applevis.com/comment/73426)).
   - A reviewer praising another app's VoiceOver support said many blind Muslims had been looking for such an app ([AppleVis](https://www.applevis.com/apps/ios/books/quran-offline-ramadan-2025)).
   - **I found no TalkBack (Android) test reports for Muslim apps**, which is a gap NURDAY could fill.

---

## 4. What builds trust

| Trust signal | Evidence |
|---|---|
| **Collecting no data at all**, with prayer times calculated on the device | The founders of Pillars built it after the Muslim Pro scandal and turned down donations ([BuzzFeed News](https://www.buzzfeednews.com/article/ikrd/pillars-app); [The Muslim Vibe](https://themuslimvibe.com/western-muslim-culture/meet-the-founders-of-the-pillars-app-the-young-muslim-duo-behind-an-innovative-new-islamic-app)). Its website says "No data whatsoever is sent to Pillars… no analytics". |
| **Few permissions** | Comparitech audited 175 Muslim apps on Google Play: 96% requested "Device ID & call information", about 40% location, 63% storage and 7% contacts. Pillars was singled out for requesting only a handful ([Comparitech](https://comparitech.com/blog/vpn-privacy/muslim-prayer-app-study), figures via search summary). **NURDAY should keep its permission list minimal and explain each one in the app.** |
| **A clean, honest Data safety label** | Recommendation guides tell users to check the Play Data safety section and the App Store privacy label ([islamtics.com](https://islamtics.com/best-islamic-apps-android/)). A similarly named app, "Muslim Pillars", lists "Contact Info linked to identity", which shows that labels get read and compared. |
| **Open source** | AlternativeTo highlights Al-Azan, Vakti, Awqat Salaat and Muezzin as open source ([AlternativeTo](https://alternativeto.net/software/al-azan--prayer-times)). It is a credibility signal, though optional. |
| **Named sources and no AI for religious content** | Egypt's Dar al-Ifta ruled AI-based Quran interpretation impermissible, citing errors, unverifiable material and no scholarly oversight ([Middle East AI News](https://www.middleeastainews.com/p/egypts-dar-al-ifta-bans-ai-for-quran); [MEA Tech Watch](https://meatechwatch.com/?p=45014)). An academic review found studies stressing "the risk of misinterpretation in AI-generated Qur'anic and Hadith content" ([USIM journal](https://jcicom.usim.edu.my/index.php/journal/article/download/125/94)). A 2025 systematic review found Muslim Pro's "Ask AiDeen" bot adequate for basic questions but weak on complex ones, needing "verification from more authoritative sources" ([BBG e-proceeding](https://eproceeding.bbg.ac.id/index.php/iconesth/article/view/296)). Some new competitors market "AI-generated Islamic guidance" (for example TaqwaTrack, [Notion support page](https://thoughtful-promise-ac7.notion.site/TaqwaTrack-Support-342b4abc594f806eb786dec536aa01d1)), which makes "no AI-generated religious content" a real point of difference. |
| **Saying "not a fatwa"** | Women's cycle apps (Tuhr, Sila) say they are "a tracking aid, not a fatwa" ([mwm.ai Tuhr](https://mwm.ai/apps/tuhr/6782219409); [Sila](https://apps.apple.com/app/id6760947127)). It is a good model for any feature touching rulings: qada, menstruation, calculation methods. |

**The incidents that made privacy a lasting concern:**
- **Muslim Pro, November 2020.** Vice/Motherboard reported that location data went to X-Mode and on to US military contractors. Muslim Pro denied selling personal data but confirmed it had shared anonymised data with X-Mode, then ended all data partnerships ([Al Jazeera](https://www.aljazeera.com/news/2020/11/17/report-us-military-buying-location-data-on-popular-muslim-apps); [Al Jazeera: denial](https://www.aljazeera.com/news/2020/11/18/muslim-pro-app-denies-selling-user-data-to-us-military)).
- **Salaat First, January 2021.** The Android app sent precise location, IP address and advertising ID to the French broker Predicio ([Vice](https://www.vice.com/en/article/muslim-app-location-data-salaat-first/); [Middle East Eye](https://www.middleeasteye.net/news/another-muslim-prayer-app-found-be-tracking-its-users-locations-report)).
- **March 2022.** Google removed apps, including Al-Moazin Lite and Qibla Compass – Ramadan 2022, that contained the Measurement Systems SDK. That SDK was linked to a US defence contractor and could read the clipboard ([Tempo](https://en.tempo.co/read/1582040/google-drops-11-apps-for-stealing-users-data-muslim-prayer-apps-included); [Android Authority](https://androidauthority.com/google-removes-spyware-apps-3150426)).

---

## 5. What makes people uninstall
(Inferred from the complaint patterns above. No source gives uninstall rates.)
- Ads appearing or increasing after an update, especially full-screen ads near prayer times (Trustpilot, the aggregator review and unstar.app cited above).
- Missed or wrong adhan alerts.
- A core feature moved behind a paywall, or an unexpected charge (*partly unverified*).
- Forced log-outs or a required account (UIN Suska study).
- Privacy news. The 2020 scandal led people to move to Pillars and similar apps (BuzzFeed).
- Losing interest after Ramadan. Religious commentators describe a predictable drop in practice after Ramadan ([Yaqeen Institute](https://yaqeeninstitute.org/watch/series/allah-loves/allah-loves-consistency-episode-20); [East London Mosque](https://www.eastlondonmosque.org.uk/blog/after-ramadan-do-i-hold-on-or-do-i-slip-back)). **I found no app-retention data on this, so it is unverified as an app metric.**

## 6. What makes people recommend an app
- "It's free, it has no ads, it doesn't sell your data." This is the stock phrasing in alternatives lists (AlternativeTo, the Al-Adhan listing, the islamtics and fiveprayer listicles, which are *commercially biased*).
- A single clear purpose done well, such as Pillars for prayer times.
- An origin story centred on privacy that the community trusts (Pillars).
- In Indonesia, a survey of 100 Gen Z respondents in Makassar found Al-Qur'an Indonesia (45%) and Muslim Pro (42%) used most. The authors put this down to ease of use, a complete feature set and attractive design ([UIN Alauddin journal](https://journal.uin-alauddin.ac.id/index.php/hisabuna/article/view/71407)). This is a small, local sample.

---

## 7. How the segments differ

| Segment | Specific needs | Evidence |
|---|---|---|
| **Young adults and professionals** | Privacy, a calm look, widgets, quick access, no feeling of being judged | Privacy-first recommendations; widget requests. Gen Z studies in Indonesia and Malaysia show regular use of Islamic apps ([UNJ journal](https://journal.unj.ac.id/unj/index.php/jsq/article/view/23727)). |
| **Converts and reverts** | Step-by-step help learning salah and wudu, transliteration, discretion (Revertly offers a "Private Mode" that disguises the app icon and keeps notifications discreet), mentors | [Revertly](https://mwm.ai/apps/revertly/6759146724), [Reverts Guide](https://apps.apple.com/us/app/reverts-guide/id6739176328). Developer listings; **I could not reach Reddit (r/converts, r/revertmuslim) to check what reverts themselves say.** |
| **Women** | Streaks and notifications that pause during menstruation or postpartum; madhab-aware hayd and istihadah rules; qada that accounts for exemptions; strong privacy for cycle data | Al-Adhan, Nisa Care, Niya, Tuhr, Sila, Waliya (developer listings; small rating counts). |
| **Students** | Free, works offline, Quran reading help | Gen Z Quran-reading survey (85 respondents) rated apps "quite effective" (UNJ, cited above). |
| **Parents and families** | Family progress, children's content, sometimes leaderboards. HalalYouNeed promotes family leaderboards. | [HalalYouNeed](https://apps.apple.com/ca/app/halalyouneed/id6758355562). **This conflicts with worries about riya'** (see below). |
| **Language and regional groups** | Indonesian and Malay (the biggest markets for Ramadan app use: penetration of Islamic apps was 9.83% in Malaysia and 7.24% in Indonesia in Ramadan 2019, per AppInsight, [WARC](https://www.warc.com/newsandopinion/news/malaysia-tops-ramadan-app-usage/en-gb/37145)); French (mosque-centred apps such as Mawaqit; **I found no usage figures**); Turkish users want the Diyanet calculation method ([Taqwa listing](https://apps.apple.com/us/app/-/id6759486499)); Urdu speakers often follow Hanafi Asr. | Cited inline |
| **Visually impaired users** | Screen-reader labels; audio | AppleVis (cited above). |

**Riya' (showing off in worship) and gamification:** Public leaderboards and sharing make worship visible. Academic work on online piety notes that scholars see riya' as seriously devaluing worship ([PMC: Online piety and its discontent](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6044233/)). My own inference, not stated by that source: **private, optional streaks are the safer design.** NURDAY's local-only approach already fits this.

---

## 8. Paraphrased user sentiments

| Sentiment (paraphrased) | Source |
|---|---|
| "The free version is basically ads now; I moved to another prayer app." | Muslim Pro reviews on Trustpilot (via search summary) |
| "I replied with a bad review and they told me to buy Pro." | Trustpilot, Muslim Pro |
| "It's become about 80% ads and 20% useful." | Play Store review from Jan 2024, via an aggregator snippet (*not seen directly*) |
| "The adhan alerts are unreliable or come late." | Analysis of 995 Muslim Pro Play Store reviews (UIN Suska) |
| "I open the app to keep the streak, not to read." | GTAF/Quran app feedback board (via search summary) |
| "Streaks are OK, just stop the pop-ups." | GTAF feedback board |
| "Let me hide the streak counter entirely." | GTAF feedback board (title of the request thread) |
| "Please give us widgets: next prayer, all five times, Hijri date." | MasjidBox feedback board |
| "The widget sometimes shows every prayer as 00:00." | MasjidBox feedback board (bug report) |
| "Show the subscription price upfront." | Tarteel review on JustUseApp |
| "Premium is too expensive." | Kimola summary of Tarteel Play Store reviews |
| "The Clear Quran is the easiest to understand; Saheeh is the most accurate." | GummySearch aggregation of Reddit |
| "Many blind Muslims have been searching for an accessible Quran app." | AppleVis review |
| "The Hijri date is a day off between UAE and India." | GitHub issue on `hijri_date` |

---

## 9. What this means for NURDAY before V1
These recommendations are my own synthesis of the evidence above.

**Must-have or quick wins before V1**
1. **Store listing and first launch should lead with trust:** "No account. No ads. No analytics. Your data never leaves your phone. Prayer times calculated on your device. Religious text shown verbatim from named sources, never AI." Link to the sources inside the app.
2. **Minimal permissions with explanations**, and a Data safety form that honestly says "no data collected / no data shared". Avoid any third-party SDK that phones home (the 2022 incident).
3. **Prayer notification reliability:** use exact alarms, and add an in-app battery-optimisation guide for Samsung, Xiaomi and Huawei. Consider a "test notification" button.
4. **Hijri date offset of ±1 or 2 days**, if not already present.
5. **Streak controls:** a hide-streaks toggle; a "pause" or excused-days mode (for menstruation, postpartum, illness, travel) that never breaks streaks; no lost-streak pop-ups ever.
6. **Accessibility pass:** TalkBack labels on every control, text scaling, contrast across all 9 themes.

**High value soon after V1**
7. Home-screen widgets: next prayer with countdown, and the Hijri date.
8. Ramadan mode: suhoor and iftar times, a fasting log in the calendar, a khatm reading plan, a nightly reflection prompt. Usage spikes sharply in Ramadan (Dulook DXB +185%).
9. Interface localisation. Suggested priority: Arabic interface with RTL, French, Indonesian and Malay, Turkish, Urdu. Recruiting volunteer translators has worked for others (Deen).
10. A qada tracker that takes menstruation exemptions into account and says it is "a tracking aid, not a fatwa".
11. Diyanet, Umm al-Qura and similar calculation-method presets shown by region.

**Avoid or let go**
- Leaderboards and social sharing of worship (riya' concerns).
- Any AI chat or AI explanation of Quran or hadith (Dar al-Ifta ruling; concern over misinterpretation).
- Nagging notifications.
- A required account.

**Unverified or still unknown**
- Actual Reddit opinion (Reddit could not be fetched).
- Uninstall and retention numbers after Ramadan.
- How many people want a qada tracker or Islamic journaling.
- French and Turkish market sizes.
- TalkBack-specific feedback.