# Releasing Nurday on Google Play

The app is built to be Play-ready, but every step below that spends money, creates an account, holds a password or uploads a release is done by a person. An agent never does these (docs/04-dev-plan.md, Phase 5).

Status: **not on Play yet.** Steps 1–3 can be done now; 4 onward need the Play Console account.

## 1. Create the upload key (once, on your own computer)
```
keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
```
- Keep `upload-keystore.jks` and both passwords in a password manager. Never commit them (`.gitignore` already blocks `*.jks` and `android/key.properties`).
- Print its SHA-1 (needed for Google Drive sign-in): `keytool -list -v -keystore upload-keystore.jks -alias upload`.

## 2. Let CI sign with it
In GitHub → the repo → Settings → Secrets and variables → Actions, add:

| Secret | Value |
|---|---|
| `UPLOAD_KEYSTORE_BASE64` | output of `base64 -w0 upload-keystore.jks` |
| `UPLOAD_KEYSTORE_PASSWORD` | keystore password |
| `UPLOAD_KEY_ALIAS` | `upload` |
| `UPLOAD_KEY_PASSWORD` | key password |

From then on every push builds release APKs signed with this key (so test installs update in place instead of needing an uninstall) and a Play bundle, `nurday-play-bundle` (`app-release.aab`), as a workflow artifact.

For a local release build instead, create `android/key.properties`:
```
storeFile=/absolute/path/to/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

## 3. Google Drive backup (optional feature, needs OAuth)
Follow README → "Google Drive backup setup". Register **two** Android OAuth clients for `com.nurday.app`: one with the upload key's SHA-1 (sideloaded test builds) and, after step 5, one with the **Play app signing** key's SHA-1 (Play Console → Test and release → App integrity). Without the second, Drive sign-in fails for people who install from Play.

Then publish the **OAuth consent screen** (Google Auth Platform → Branding and Audience): app name Nurday, logo (`docs/store/icon-512.png`), support email lebapplications@gmail.com, privacy policy URL (step 7), and set it to **In production**. Check under Data access how Google classes `drive.appdata`. If it is listed as sensitive, submit the app for OAuth verification; until it passes, users see an "unverified app" warning and sign-ins are capped at 100 users.

## 4. Play Console account
- Create a developer account at https://play.google.com/console (one-time US$25, identity verification).
- New personal accounts must run a **closed test with at least 12 testers for 14 days** before production access. Plan for this.

## 5. Create the app
- App name **Nurday**, default language English, App, Free.
- Enroll in **Play App Signing** (default). Upload `app-release.aab` from the CI artifact to **Internal testing** first.
- Package name is fixed forever: `com.nurday.app`.

## 6. Store listing
Copy from [docs/store-listing.md](docs/store-listing.md). Needs: 512×512 icon and 1024×500 feature graphic (`docs/store/`), 2–8 phone screenshots (CI release `store-assets`). Describe mood as a wellness check-in, never as mental-health support, and never call the journal lock encryption.

## 7. Policy forms
- **Privacy policy URL**: the Notion page "Nurday privacy policy" (under Android Projects → Nurday) with Share → Publish turned on; paste its `notion.site` link. Check it opens in a private browser window without login, and keep it identical to [PRIVACY.md](PRIVACY.md).
- **Health apps declaration**: the app has no health features. Mood is a wellness check-in, not a health or mental-health feature.
- **App access**: all features available without login.
- **Ads**: no ads.
- **Content rating** (IARC questionnaire): reference app; no violence, sexual content, gambling, or user-to-user communication; religious text is shown. Expected rating: Everyone / PEGI 3.
- **Target audience**: 13+ (not designed for children; avoids Families policy requirements).
- **Data safety**: see the table below. Re-check against Play's current definitions when filling it in; they change.

### Data safety answers (draft for the person filling the form)
| Question | Answer and why |
|---|---|
| Does the app collect or share user data? | Yes, see below. Everything else stays on the phone. |
| Approximate location | **Collected**, not shared, optional, not stored off device. Rounded coordinates go to Open-Meteo to get weather, and to Android's system geocoder to name the place, only after "Use my location". Purpose: App functionality. |
| Personal info, messages, photos, contacts, health, financial | Not collected. |
| App activity → In-app search history | **Collected**, not shared, not stored. The city text typed in Settings → Location goes to Open-Meteo's geocoder to suggest places; it is processed ephemerally. Purpose: App functionality. |
| Other app activity / app info and performance | Not collected (no analytics, no crash reporting). |
| Android cloud backup | Off: `allowBackup="false"` and data extraction rules exclude everything, so Android does not copy the database to Google. |
| Journal, mood, habits, activities (user-generated content) | Only if the user turns on Google Drive backup or exports a file: sent to the user's **own** Google Drive app folder or a file they pick. Declare as **User-generated content → Collected, optional, user-initiated**, purpose: App functionality / backup. |
| Is data encrypted in transit? | Yes (HTTPS to Open-Meteo, AlQuran Cloud, Google). |
| Can users request deletion? | Yes: uninstall or clear storage deletes everything; Drive backup is deleted from Google Drive → Manage apps. |
| Fingerprint / face | Not collected. Android checks it; the app only learns "unlocked or not". |

### Sensitive permissions to justify if asked
| Permission | Why |
|---|---|
| `ACCESS_COARSE_LOCATION` | Weather and prayer times; requested only on tap; a typed city works instead. |
| `POST_NOTIFICATIONS` | Reminders and prayer alerts the user turns on. |
| `RECEIVE_BOOT_COMPLETED` | Reschedule those reminders after a restart. |
| `USE_BIOMETRIC` | Optional journal lock. |
| `SCHEDULE_EXACT_ALARM` | Prayer alerts at the exact minute of each prayer. Not granted by default on Android 14+; the user allows it from Settings → Prayer, otherwise alerts are inexact. No Play declaration is needed (only `USE_EXACT_ALARM` needs one, and Nurday does not request it). |

No `USE_EXACT_ALARM`, background-location, contacts, storage or camera permissions are requested.

### Content licences
Tafsir (Al-Muyassar from KFGQPC, Al-Mukhtasar from Tafsir Center), the English hadith translations and the OpenITI quotes are used unchanged, with attribution, in a free app. Adding ads, a price or in-app purchases re-opens these licences; check each one first.

## 8. Before each release
1. Bump `version:` in `pubspec.yaml` (`name+code`; the code must always increase).
2. Move the CHANGELOG "unreleased" section to the new version.
3. CI green on the release commit; download `nurday-play-bundle`.
4. Upload to Internal testing → install from Play on a real phone → check Today, Habits, Journal, backup export/import, reminders.
5. Promote to closed testing / production in Play Console.

## Not done by agents
Buying or signing in to the Play Console, creating or storing keystores or passwords, adding GitHub secrets, uploading bundles, filling Play forms, pressing "Send for review".
