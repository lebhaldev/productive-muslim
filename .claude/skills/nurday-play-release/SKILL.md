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
4. CI must be green; with the secrets set it uploads `nurday-play-bundle` (the `.aab`).
5. Any new permission, network host or data leaving the phone → update the permission and Data safety tables in RELEASE.md, PRIVACY.md (date it), FR-10/TR-9 in the specs. Prefer designs that need no new permission.
6. New user-visible features → update the full description in `docs/store-listing.md` and the screenshot list.
7. Play policy pitfalls to avoid: exact alarms, background location, broad storage access, collecting data without a disclosure, religious content without attribution, ads or analytics SDKs.

## Things only the owner can do
Play Console account (US$25, identity check, 12-tester closed test for 14 days on new personal accounts), upload key creation, GitHub secrets, OAuth clients (upload key SHA-1 and Play app-signing SHA-1 for Drive sign-in), hosting the privacy policy, uploading the bundle, filling Data safety / content rating, sending for review.
