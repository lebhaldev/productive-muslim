# Nurday privacy policy

Last updated: 7 October 2026

Nurday keeps your personal data on your phone.

## Data that stays on this device
Your journal entries, mood, habits, habit check-offs, activities and settings are stored in a local database on your phone. Nurday has no account and no server of its own. They leave the phone only if you choose one of the backups below.

## Backups (optional, off by default)
- **Export to a file**: Settings → Backup → Export saves a JSON file wherever you choose. The file is not encrypted.
- **Google Drive**: if you tap "Connect Google Drive", Nurday asks Google for access to its own hidden app folder in *your* Drive (scope `drive.appdata`) and saves one backup file there, about once a day. Nurday cannot see any other file in your Drive, and the backup is not sent anywhere else. "Disconnect" stops backups and removes Nurday's access; the backup file stays in your Drive until you delete it (Google Drive → Settings → Manage apps → Nurday → Delete hidden app data).

## Journal lock
If you turn on Settings → Privacy → Lock journal, Nurday asks Android to check your fingerprint, face or screen lock. Nurday never sees or stores the fingerprint, face or PIN.

## Location
Location is optional. It is only requested when you tap "Use my location" in Settings, and it is used only to ask Open-Meteo for your local weather. Coordinates are rounded to about 1 km and are not stored anywhere except on your phone. You can search for a city instead. To show the place name, the app asks Android's built-in geocoder (part of the phone's system services, usually provided by Google) to name the rounded coordinates once; the name is kept on your phone.

## Network requests
Nurday contacts only these services:
- **AlQuran Cloud** (api.alquran.cloud) and **Quran.com** (api.quran.com) to fetch the day's ayah. The request contains the ayah reference only.
- **Open-Meteo** (api.open-meteo.com, geocoding-api.open-meteo.com) for weather. The request contains the city text you type in the search box (to suggest matching places) or rounded coordinates.
- **Google** (Google sign-in and www.googleapis.com) only if you connect Google Drive backup, to save and read the backup file.

Hadith and quotes are bundled inside the app and need no network.

## Notifications
Reminders are scheduled on the phone with Android's local notifications. Nothing is sent to a server.

## No tracking
Nurday contains no analytics, advertising or crash-reporting SDKs.

## Deleting your data
Uninstalling the app, or clearing its storage in Android settings, deletes everything.

## Contact
Open an issue at https://github.com/lebhaldev/productive-muslim.
