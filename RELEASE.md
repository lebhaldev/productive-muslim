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

## 4. Play Console account
- Create a developer account at https://play.google.com/console (one-time US$25, identity verification).
- New personal accounts must run a **closed test with at least 12 testers for 14 days** before production access. Plan for this.

## 5. Create the app
- App name **Nurday**, default language English, App, Free.
- Enroll in **Play App Signing** (default). Upload `app-release.aab` from the CI artifact to **Internal testing** first.
- Package name is fixed forever: `com.nurday.app`.

## 6. Store listing
Copy from [docs/store-listing.md](docs/store-listing.md). Needs: 512×512 icon (`assets/icon/icon.png` scaled), 1024×500 feature graphic, 2–8 phone screenshots (list in that file).

## 7. Policy forms
- **Privacy policy URL**: host [PRIVACY.md](PRIVACY.md) publicly (for example GitHub Pages) and paste the URL.
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
| App activity / app info and performance | Not collected (no analytics, no crash reporting). |
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

No exact-alarm, background-location, contacts, storage or camera permissions are requested.

## 8. Before each release
1. Bump `version:` in `pubspec.yaml` (`name+code`; the code must always increase).
2. Move the CHANGELOG "unreleased" section to the new version.
3. CI green on the release commit; download `nurday-play-bundle`.
4. Upload to Internal testing → install from Play on a real phone → check Today, Habits, Journal, backup export/import, reminders.
5. Promote to closed testing / production in Play Console.

## Not done by agents
Buying or signing in to the Play Console, creating or storing keystores or passwords, adding GitHub secrets, uploading bundles, filling Play forms, pressing "Send for review".
