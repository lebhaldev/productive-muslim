---
name: nurday-play-release
description: Steps and guardrails for shipping Nurday to Google Play — versioning, upload-key signing, CI bundle, Data safety, store listing. Use when preparing a release, changing permissions or data flows, or when the user mentions the Play Store.
---

# Nurday → Google Play

The goal is publishing on Play. Agents prepare everything; a person does anything involving money, accounts, keys, passwords, uploads or Play forms. The full human checklist is `RELEASE.md`; listing copy is `docs/store-listing.md`.

## Agent checklist for a release-ready commit
1. Bump `version:` in `pubspec.yaml` (`x.y.z+code`, code always increases) and date the CHANGELOG section.
2. Keep `applicationId` `com.nurday.app`; never change it.
3. Release signing: `android/app/build.gradle.kts` reads `android/key.properties` (or CI writes it from `UPLOAD_KEYSTORE_*` secrets). Never create, commit or print keystores or passwords; `.gitignore` blocks them.
4. CI must be green. The `UPLOAD_KEYSTORE_*` secrets are set (since 2026-10-10): CI checks the bundle's signer and publishes the signed `.aab` at release tag `play-bundle` (`play-bundle/nurday-play.aab`). Fetch it with `curl -L` and hand it to the owner. Release name in Play: `x.y.z (code)`.
5. Any new permission, network host or data leaving the phone → update the permission and Data safety tables in RELEASE.md, PRIVACY.md (date it), FR-10/TR-9 in the specs. Prefer designs that need no new permission.
6. New user-visible features → update the full description in `docs/store-listing.md` and the screenshot list.
7. Keep the app matching what Play Console declares (`docs/play-console.md`): no ads, no `AD_ID` (manifest removes it; test + CI check), Data safety = approximate location, in-app search history, user content only to the user's own Drive. Any new SDK that collects data → update Data safety first.
8. Play policy pitfalls to avoid: exact alarms, background location, broad storage access, collecting data without a disclosure, religious content without attribution, ads or analytics SDKs.

## Play Console state
App created 2026-10-11 (app ID 4974783829983018374), Play App Signing on, 1.0.0 (4) on internal testing. Full record and open items: `docs/play-console.md`; status line at the top of RELEASE.md. Update both when the console changes.

## Driving Play Console
A cloud session can see the owner's Chrome only read-only and cannot make the upload key. The working route: write a step-by-step prompt for the owner to paste into **Claude in Chrome** (see `/mnt/project-files/nurday/play/claude-in-chrome-instructions.txt`): parts for privacy page, create app, App content, listing, release; never "Send for review"/"Publish"/production rollout; the owner picks files in file pickers. Give direct file links or a zip, not a release folder URL. Ask Chrome-Claude to write back a status file like `docs/play-console.md`.

## Things only the owner can do
Play Console account (US$25, identity check, 12-tester closed test for 14 days on new personal accounts), upload key creation, GitHub secrets, OAuth clients (upload key SHA-1 and Play app-signing SHA-1 for Drive sign-in), hosting the privacy policy, uploading the bundle, filling Data safety / content rating, sending for review.
