import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/backup.dart';
import '../../data/content/quran_client.dart';
import '../../data/drive_backup.dart';
import '../../data/prayer/prayer.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import 'more_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _city = TextEditingController();
  bool _cityLoaded = false;
  String? _locationNote;

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  Future<void> _put(String key, String value) =>
      ref.read(databaseProvider).putSetting(key, value);

  String? _reminderNote;

  Future<void> _setDailyReminder(bool on) async {
    if (on && !await ref.read(reminderSchedulerProvider).requestPermission()) {
      setState(
        () => _reminderNote = 'Notifications are off for Nurday. Allow them in Android settings to get reminders.',
      );
      await _put('dailyReminderOn', 'false');
      return;
    }
    setState(() => _reminderNote = null);
    await _put('dailyReminderOn', '$on');
  }

  String? _prayerNote;

  Future<void> _setPrayerAlerts(bool on) async {
    if (on && !await ref.read(reminderSchedulerProvider).requestPermission()) {
      setState(
        () => _prayerNote = 'Notifications are off for Nurday. Allow them in Android settings to get prayer alerts.',
      );
      await _put('prayerAlerts', 'false');
      return;
    }
    setState(() => _prayerNote = null);
    await _put('prayerAlerts', '$on');
  }

  Future<void> _saveCity() async {
    await _put('city', _city.text.trim());
    await _put('lat', '');
    await _put('lon', '');
    ref.invalidate(weatherProvider);
  }

  /// Location is requested only here, on tap, and used only for weather (TR-8).
  Future<void> _useLocation() async {
    setState(() => _locationNote = 'Finding your location…');
    try {
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      if (p == LocationPermission.denied ||
          p == LocationPermission.deniedForever) {
        setState(
          () => _locationNote =
              'Location permission was not granted. Type a city instead.',
        );
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      await _put('lat', pos.latitude.toStringAsFixed(2));
      await _put('lon', pos.longitude.toStringAsFixed(2));
      ref.invalidate(weatherProvider);
      setState(() => _locationNote = 'Using your location for weather.');
    } catch (_) {
      setState(
        () => _locationNote = 'Location is unavailable. Type a city instead.',
      );
    }
  }

  String? _backupNote;
  String? _lockNote;
  String? _driveNote;
  bool _driveBusy = false;

  Future<void> _drive(Future<String?> Function(DriveSync d) action) async {
    setState(() {
      _driveBusy = true;
      _driveNote = null;
    });
    String? note;
    try {
      note = await action(ref.read(driveSyncProvider));
    } on DriveException catch (e) {
      note = e.message;
    } on BackupException catch (e) {
      note = e.message;
    } catch (_) {
      note = 'Google Drive is not available right now.';
    }
    if (!mounted) return;
    setState(() {
      _driveBusy = false;
      _driveNote = note;
    });
  }

  Future<void> _driveRestore() async {
    final mode = await _askImportMode();
    if (mode == null) return;
    await _drive((d) async {
      final summary = await d.restore(mode);
      if (summary == null) return 'No backup found in your Google Drive.';
      ref.invalidate(weatherProvider);
      return summary.isEmpty
          ? 'Nothing new in the Drive backup.'
          : 'Restored $summary.';
    });
  }

  Future<void> _setJournalLock(bool on) async {
    final lock = ref.read(appLockProvider);
    if (on && !await lock.available()) {
      setState(
        () => _lockNote =
            'Set up a screen lock in Android settings first, then try again.',
      );
      return;
    }
    // Confirm it is really the owner, both to turn it on and to turn it off.
    if (!await lock.unlock(
      on ? 'Lock your Nurday journal' : 'Turn off the journal lock',
    )) {
      return;
    }
    setState(() => _lockNote = null);
    await _put('journalLock', '$on');
    ref.read(journalUnlockedProvider.notifier).set(false);
  }

  Future<void> _export() async {
    final db = ref.read(databaseProvider);
    final now = ref.read(clockProvider).now();
    try {
      final saved = await ref
          .read(backupFilesProvider)
          .save(backupFileName(now), await db.exportJson(now));
      if (saved) setState(() => _backupNote = 'Backup saved.');
    } catch (_) {
      setState(() => _backupNote = 'The backup could not be saved.');
    }
  }

  Future<ImportMode?> _askImportMode() => showDialog<ImportMode>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Import backup'),
      content: const Text(
        'Merge adds the backup to what is on this phone. '
        'Replace deletes everything on this phone first.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, ImportMode.replace),
          child: const Text('Replace'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, ImportMode.merge),
          child: const Text('Merge'),
        ),
      ],
    ),
  );

  Future<void> _import() async {
    final String? source;
    try {
      source = await ref.read(backupFilesProvider).open();
    } catch (_) {
      setState(() => _backupNote = 'The file could not be read.');
      return;
    }
    if (source == null || !mounted) return;
    final mode = await _askImportMode();
    if (mode == null) return;
    try {
      final summary = await ref.read(databaseProvider).importJson(source, mode);
      setState(
        () => _backupNote = summary.isEmpty
            ? 'Nothing new in this backup.'
            : 'Imported $summary.',
      );
      ref.invalidate(weatherProvider);
    } on BackupException catch (e) {
      setState(() => _backupNote = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = settingsOf(ref);
    if (!_cityLoaded && ref.watch(settingsProvider).hasValue) {
      _city.text = s.city;
      _cityLoaded = true;
    }

    return ScreenBody(
      children: [
        const SubScreenTitle('Settings'),
        NCard(
          gap: 10,
          children: [
            const CardTitle('Weather'),
            TextField(
              controller: _city,
              decoration: const InputDecoration(labelText: 'City override'),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _saveCity(),
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
                if (_city.text.trim() != s.city) _saveCity();
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _useLocation,
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text('Use my location'),
              ),
            ),
            if (_locationNote != null) Text(_locationNote!, style: meta()),
            Text(
              'Location is sent only to Open-Meteo for weather. Prayer times '
              'and Qibla are calculated on this phone from it.',
              style: meta(),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Celsius')),
                  ButtonSegment(value: true, label: Text('Fahrenheit')),
                ],
                selected: {s.fahrenheit},
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.sage300,
                ),
                onSelectionChanged: (v) => _put('unit', v.first ? 'F' : 'C'),
              ),
            ),
          ],
        ),
        NCard(
          gap: 10,
          children: [
            const CardTitle('Appearance'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final t in ColorTheme.values)
                  _ThemeSwatch(
                    theme: t,
                    selected: s.colorTheme == t,
                    onTap: () => _put('colorTheme', t.name),
                  ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<ThemeMode>(
                key: const Key('theme-mode'),
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('System')),
                  ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ],
                selected: {s.themeMode},
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.sage300,
                ),
                onSelectionChanged: s.colorTheme.alwaysDark
                    ? null
                    : (v) => _put('themeMode', v.first.name),
              ),
            ),
            if (s.colorTheme.alwaysDark)
              Text('Night is always dark, for OLED screens.', style: meta()),
          ],
        ),
        NCard(
          gap: 10,
          children: [
            const CardTitle('Prayer'),
            DropdownButtonFormField<PrayerMethod>(
              key: ValueKey(ref.watch(prayerMethodProvider)),
              initialValue: ref.watch(prayerMethodProvider),
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Calculation method',
              ),
              items: [
                for (final m in PrayerMethod.values)
                  DropdownMenuItem(
                    value: m,
                    child: Text(m.label, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (m) {
                if (m != null) _put('prayerMethod', m.name);
              },
            ),
            DropdownButtonFormField<AsrMadhab>(
              initialValue: s.madhab,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Asr'),
              items: [
                for (final m in AsrMadhab.values)
                  DropdownMenuItem(
                    value: m,
                    child: Text(m.label, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (m) {
                if (m != null) {
                  _put('madhab', m == AsrMadhab.hanafi ? 'hanafi' : 'shafi');
                }
              },
            ),
            DropdownButtonFormField<HighLatitude>(
              initialValue: s.highLatitude,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'High latitude rule (far north or south)',
              ),
              items: [
                for (final h in HighLatitude.values)
                  DropdownMenuItem(value: h, child: Text(h.label)),
              ],
              onChanged: (h) {
                if (h != null) _put('highLatitude', h.name);
              },
            ),
            SwitchListTile(
              key: const Key('prayer-alerts-switch'),
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Prayer time notifications',
                style: TextStyle(fontSize: 15),
              ),
              value: s.prayerAlerts,
              activeTrackColor: AppColors.sage600,
              onChanged: _setPrayerAlerts,
            ),
            if (_prayerNote != null)
              Text(_prayerNote!, style: meta(color: AppColors.accent700)),
            Text(
              'Times are calculated on this phone from your weather location.',
              style: meta(),
            ),
          ],
        ),
        NCard(
          gap: 10,
          children: [
            const CardTitle('Content'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Show faith cards',
                style: TextStyle(fontSize: 15),
              ),
              value: s.showFaith,
              activeTrackColor: AppColors.sage600,
              onChanged: (v) => _put('faith', '$v'),
            ),
            DropdownButtonFormField<Translation>(
              initialValue: s.translation,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Translation'),
              items: [
                for (final t in Translation.values.where((t) => t.offered))
                  DropdownMenuItem(
                    value: t,
                    child: Text(t.label, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (t) {
                if (t != null) _put('translation', t.name);
              },
            ),
            DropdownButtonFormField<bool>(
              initialValue: s.arabicOnly,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Content language'),
              items: const [
                DropdownMenuItem(value: false, child: Text('Arabic + English')),
                DropdownMenuItem(value: true, child: Text('Arabic only')),
              ],
              onChanged: (v) {
                if (v != null) _put('contentLanguage', v ? 'ar' : 'ar_en');
              },
            ),
          ],
        ),
        NCard(
          children: [
            const CardTitle('Reminders'),
            Row(
              children: [
                const Expanded(
                  child: Text('Daily reminder', style: TextStyle(fontSize: 15)),
                ),
                Switch(
                  key: const Key('daily-reminder-switch'),
                  value: s.dailyReminderOn,
                  activeTrackColor: AppColors.sage600,
                  onChanged: _setDailyReminder,
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: !s.dailyReminderOn
                      ? null
                      : () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: parseHhmm(s.dailyReminder),
                          );
                          if (t != null) await _put('dailyReminder', hhmm(t));
                        },
                  child: Text(s.dailyReminder),
                ),
              ],
            ),
            if (_reminderNote != null)
              Text(_reminderNote!, style: meta(color: AppColors.accent700)),
            Text('Per-habit reminders are set on each habit.', style: meta()),
          ],
        ),
        NCard(
          gap: 10,
          children: [
            const CardTitle('Privacy'),
            SwitchListTile(
              key: const Key('journal-lock-switch'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Lock journal', style: TextStyle(fontSize: 15)),
              subtitle: Text(
                'Asks for your fingerprint, face or screen lock to read it.',
                style: meta(),
              ),
              value: s.journalLock,
              activeTrackColor: AppColors.sage600,
              onChanged: _setJournalLock,
            ),
            if (_lockNote != null)
              Text(_lockNote!, style: meta(color: AppColors.accent700)),
          ],
        ),
        NCard(
          gap: 10,
          children: [
            const CardTitle('Backup'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const Key('export-backup'),
                  onPressed: _export,
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Export'),
                ),
                OutlinedButton.icon(
                  key: const Key('import-backup'),
                  onPressed: _import,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Import'),
                ),
              ],
            ),
            if (_backupNote != null) Text(_backupNote!, style: meta()),
            const Divider(height: 12),
            Text('Google Drive', style: TextStyle(fontWeight: FontWeight.w600)),
            if (!s.driveBackup)
              Text(
                'Back up once a day to a hidden Nurday folder in your own '
                'Google Drive. Nurday cannot see your other files and has no '
                'server or account of its own.',
                style: meta(),
              )
            else
              Text(
                s.driveLastBackup == null
                    ? 'Backs up once a day.'
                    : 'Backs up once a day · last backup '
                          '${DateFormat('d MMM, HH:mm').format(s.driveLastBackup!)}',
                style: meta(),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: s.driveBackup
                  ? [
                      OutlinedButton(
                        key: const Key('drive-backup-now'),
                        onPressed: _driveBusy
                            ? null
                            : () => _drive(
                                (d) async => await d.backUp()
                                    ? 'Backed up to Google Drive.'
                                    : null,
                              ),
                        child: const Text('Back up now'),
                      ),
                      OutlinedButton(
                        key: const Key('drive-restore'),
                        onPressed: _driveBusy ? null : _driveRestore,
                        child: const Text('Restore'),
                      ),
                      TextButton(
                        key: const Key('drive-disconnect'),
                        onPressed: _driveBusy
                            ? null
                            : () => _drive((d) async {
                                await d.disconnect();
                                return 'Google Drive disconnected. Your backup stays in Drive.';
                              }),
                        child: const Text('Disconnect'),
                      ),
                    ]
                  : [
                      OutlinedButton.icon(
                        key: const Key('drive-connect'),
                        onPressed: _driveBusy
                            ? null
                            : () => _drive(
                                (d) async => await d.connect()
                                    ? 'Backed up to Google Drive.'
                                    : null,
                              ),
                        icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                        label: const Text('Connect Google Drive'),
                      ),
                    ],
            ),
            if (_driveNote != null) Text(_driveNote!, style: meta()),
            Text(
              'Saves habits, moods, activities, journal and settings to a file '
              'you choose. The file is not encrypted, so keep it private.',
              style: meta(),
            ),
          ],
        ),
        NCard(
          gap: 6,
          color: AppColors.sage200,
          children: [
            Text(
              'Your data stays on this phone',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.sage900,
              ),
            ),
            Text(
              s.driveBackup
                  ? 'Nurday has no server and no account. A daily backup goes '
                        'only to your own Google Drive.'
                  : 'Journal, mood, habits and activities are never uploaded. No account needed.',
              style: TextStyle(fontSize: 13, color: AppColors.sage900),
            ),
          ],
        ),
        const NCard(
          gap: 6,
          children: [
            CardTitle('Sources & licenses'),
            Text(
              'Quran: AlQuran Cloud (Uthmani text, Saheeh International) · '
              'Hadith: Sahih al-Bukhari and Sahih Muslim, Arabic and English from the '
              'fawazahmed0/hadith-api dataset (public domain); English by Muhammad Muhsin Khan '
              'and Abdul Hamid Siddiqui; Bukhari references to sunnah.com · '
              'Prayer times: adhan library (MIT), calculated on this phone · '
              'Hijri date: Umm al-Qura calendar (hijri library) · '
              'Weather: Open-Meteo (CC BY 4.0) · Quotes: Arabic texts from the OpenITI corpus '
              '(Diwan al-Shafi\'i, al-Mutanabbi, Ibn al-Jawzi\'s Sayd al-Khatir) · '
              'Fonts: Amiri Quran and Fraunces (SIL Open Font License)',
              style: TextStyle(fontSize: 13, height: 1.6),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.theme,
    required this.selected,
    required this.onTap,
  });
  final ColorTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = theme.paletteFor(Theme.of(context).brightness);
    return Semantics(
      button: true,
      selected: selected,
      label: '${theme.label} colours',
      excludeSemantics: true,
      child: InkWell(
        key: Key('color-theme-${theme.name}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              AnimatedContainer(
                duration: motion(context, Motion.quick),
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.text : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Container(
                    color: p.bg,
                    child: Row(
                      children: [
                        Expanded(child: Container(color: p.accent700)),
                        Expanded(child: Container(color: p.sage600)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                theme.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
