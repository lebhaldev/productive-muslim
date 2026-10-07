import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../data/backup.dart';
import '../../data/drive_backup.dart';
import '../../widgets/common.dart';

class BackupSection extends ConsumerStatefulWidget {
  const BackupSection({super.key});

  @override
  ConsumerState<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<BackupSection> {
  String? _fileNote;
  String? _driveNote;
  bool _driveBusy = false;

  void _setFileNote(String? note) {
    if (mounted) setState(() => _fileNote = note);
  }

  String _summaryNote(ImportSummary s, String verb) =>
      s.isEmpty ? 'Nothing new in this backup.' : '$verb $s.';

  Future<void> _export() async {
    final now = ref.read(clockProvider).now();
    try {
      final json = await ref.read(databaseProvider).exportJson(now);
      if (await ref.read(backupFilesProvider).save(backupFileName(now), json)) {
        _setFileNote('Backup saved.');
      }
    } catch (_) {
      _setFileNote('The backup could not be saved.');
    }
  }

  Future<void> _import() async {
    final String? source;
    try {
      source = await ref.read(backupFilesProvider).open();
    } catch (_) {
      _setFileNote('The file could not be read.');
      return;
    }
    if (source == null) return;
    final mode = await _askImportMode();
    if (mode == null) return;
    try {
      final summary = await ref.read(databaseProvider).importJson(source, mode);
      ref.invalidate(weatherProvider);
      _setFileNote(_summaryNote(summary, 'Imported'));
    } on BackupException catch (e) {
      _setFileNote(e.message);
    }
  }

  Future<ImportMode?> _askImportMode() async {
    if (!mounted) return null;
    return showDialog<ImportMode>(
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
  }

  /// Runs one Drive action with the buttons disabled, then shows its note.
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
      return _summaryNote(summary, 'Restored');
    });
  }

  VoidCallback? _whenIdle(Future<String?> Function(DriveSync d) action) =>
      _driveBusy ? null : () => _drive(action);

  @override
  Widget build(BuildContext context) {
    final s = settingsOf(ref);
    final last = s.driveLastBackup;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NCard(
          gap: 10,
          children: [
            const CardTitle('File'),
            const Note(
              'Saves habits, moods, activities, journal and settings to a file '
              'you choose. The file is not encrypted, so keep it private.',
            ),
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
            if (_fileNote != null) Note(_fileNote!),
          ],
        ),
        const SizedBox(height: 14),
        NCard(
          gap: 10,
          children: [
            const CardTitle('Google Drive'),
            Note(
              !s.driveBackup
                  ? 'Back up once a day to a hidden Nurday folder in your own '
                        'Google Drive. Nurday cannot see your other files and '
                        'has no server or account of its own.'
                  : last == null
                  ? 'Backs up once a day.'
                  : 'Backs up once a day · last backup '
                        '${DateFormat('d MMM, HH:mm').format(last)}',
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: s.driveBackup
                  ? [
                      OutlinedButton(
                        key: const Key('drive-backup-now'),
                        onPressed: _whenIdle(
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
                        onPressed: _whenIdle((d) async {
                          await d.disconnect();
                          return 'Google Drive disconnected. '
                              'Your backup stays in Drive.';
                        }),
                        child: const Text('Disconnect'),
                      ),
                    ]
                  : [
                      OutlinedButton.icon(
                        key: const Key('drive-connect'),
                        onPressed: _whenIdle(
                          (d) async => await d.connect()
                              ? 'Backed up to Google Drive.'
                              : null,
                        ),
                        icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                        label: const Text('Connect Google Drive'),
                      ),
                    ],
            ),
            if (_driveNote != null) Note(_driveNote!),
          ],
        ),
      ],
    );
  }
}
