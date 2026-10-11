# Nurday – Google Play Console setup (status as of 2026-10-11)

Context for Claude Code: the Play Console side of Nurday has been configured, and a first internal test release is live. Use this file as the source of truth for store and policy decisions. Keep the app's behaviour consistent with these declarations.

## Identifiers

| Item | Value |
|---|---|
| Developer account | LebApps ("Leb Apps"), ID `7378064386987289396`, owner lebhal@gmail.com |
| App ID (Console) | `4974783829983018374` |
| Package name | `com.nurday.app` |
| Default language | en-US |
| Type / price | App, Free |
| Category | Lifestyle |
| Contact email | lebapplications@gmail.com |
| Privacy policy + website | https://aleb.notion.site/Nurday-privacy-policy-3f5b2c91a0b881439d2fd240a1c75e90 (Notion page "Nurday privacy policy", published to web) |
| Internal testing track ID | `4700892133865162987` |
| Tester opt-in link | https://play.google.com/apps/internaltest/4700892133865162987 |

## Release on the internal testing track

- Release name **1.0.0 (4)**, versionCode **4**, versionName **1.0.0**. Status: available to internal testers, rolled out 2026-10-11. It has not been reviewed, so testers see the temporary name "com.nurday.app (unreviewed)".
- Bundle: `nurday-play.aab`, minSdk 24, targetSdk 36, about 11 MB on install.
- Release notes (en-US): "First release of Nurday."
- **Play App Signing is ON (Google-generated app signing key).** The local keystore is now only the *upload key*.
- Tester email list "Leb Apps team": lebapplications@gmail.com, lebhal@gmail.com, ayoub.lebhal@gmail.com. Install works.

## Action items for the codebase

1. **Google Drive backup / Google Sign-In.** Builds installed from Play are re-signed with Google's app signing key. Register that key in the Google Cloud OAuth client for Android, or Drive sign-in will fail for Play installs (DEVELOPER_ERROR / code 10).
   - Get the key's SHA-1 from Play Console → Test and release → App integrity → App signing.
   - Add it next to the upload key and debug SHA-1s (package `com.nurday.app`).
2. **Next upload must use versionCode ≥ 5.** Each release name should follow the pattern `x.y.z (versionCode)`.
3. **Advertising ID declaration is still open** (Policy → App content). The app has no ads or analytics, so the answer should be "No".
   - Check the merged manifest has no `com.google.android.gms.permission.AD_ID`. A library can add it.
   - If a library adds it, remove it with `tools:node="remove"`. Android 13+ releases are blocked until this is declared.
4. Keep the app matching the declarations below. If you add any SDK that collects data, the Data safety form must be updated first.

## Policy declarations (App content), all saved

- **Privacy policy:** URL above.
- **App access:** no restricted parts. The optional journal lock (biometric/screen lock) is not treated as gated access.
- **Ads:** no ads.
- **Content rating (IARC):** email lebapplications@gmail.com. Category "All other app types" (the "Reference/News/Educational" category was not offered).
  - "Yes" only to "primarily news or educational".
  - "No" to everything else: rating-relevant content, user interaction/sharing, online content outside the package, age-restricted goods, precise location sharing, digital purchases, cash/NFT rewards, web browser.
- **Target audience:** 18+ only. Not designed for children.
- **Health apps:** no health features (mood is a wellness check-in).
- **Financial features:** none. **Government app:** no.
- **News app:** this declaration was not presented.

### Data safety

- Collects or shares user data: **Yes**. Encrypted in transit: **Yes**.
- Accounts: the app does not allow account creation. Login with an external account: **No** (Google sign-in is only used to authorize the Drive backup).
- Users can request deletion: **Yes**. The deletion URL is the privacy policy (uninstall or clear storage; there are no accounts).
- Shared with third parties: nothing.

| Data type | Collected | Shared | Ephemeral | Optional | Purpose |
|---|---|---|---|---|---|
| Location → Approximate location | Yes | No | Yes | Yes | App functionality (weather) |
| App activity → In-app search history | Yes | No | Yes | Yes | App functionality (city search text sent to Open-Meteo) |
| App activity → Other user-generated content | Yes | No | **No** (stored in the user's own Drive) | Yes (only if Drive backup is on) | App functionality |

Everything else is declared **not collected**: personal info, financial, health, messages, photos/videos, audio, files, calendar, contacts, web browsing, app info and performance (no crash reporting or analytics), device IDs.

## Store listing (default, en-US), saved

- **Title:** Nurday: Ayah, Habits, Journal
- **Short description:** A calm daily companion: an ayah with tafsir, a hadith, habits, mood and journal.
- **Full description:** the "Nurday is a calm, private place for your day as a Muslim…" text, with the sections Each day / Your rhythm / Prayer and weather / Private by design / Made with care.
- **Graphics** (from `store-assets` release / `nurday-store-graphics.zip`):
  - `icon-512.png` (512×512)
  - `feature-graphic.png` (1024×500)
  - 8 phone screenshots at 1080×2340, in this order: `1-today`, `2-ayah-hadith-quote`, `3-habits`, `4-calendar`, `5-journal`, `6-prayer`, `7-themes`, `8-today-night`
- **AI-generated assets declaration:** the icon and feature graphic are labelled as made or modified with AI. The screenshots are not labelled.
- **Other defaults left on:** Play "automatic protection" (installer check) is on. That's why the bundle shows "Vue améliorée" and the console suggests re-uploading to apply improvements.

## Not done yet / before production

- [ ] Advertising ID declaration (see action item 3).
- [ ] Add the Play app signing SHA-1 to the Google Cloud OAuth client (action item 1), then test Drive backup on the Play-installed build.
- [ ] Nothing has been sent for review or published to production. "Send for review", production rollout and closed or open testing are all untouched.
- [ ] If this is a new personal developer account, Google may require a closed test (12+ testers for 14 days) before production access. Check the Dashboard.
