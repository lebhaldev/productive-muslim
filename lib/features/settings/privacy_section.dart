import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../widgets/common.dart';
import 'settings_widgets.dart';

class PrivacySection extends ConsumerStatefulWidget {
  const PrivacySection({super.key});

  @override
  ConsumerState<PrivacySection> createState() => _PrivacySectionState();
}

class _PrivacySectionState extends ConsumerState<PrivacySection> {
  String? _note;

  Future<void> _setJournalLock(bool on) async {
    final lock = ref.read(appLockProvider);
    if (on && !await lock.available()) {
      setState(
        () => _note =
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
    if (mounted) setState(() => _note = null);
    await ref.putSetting('journalLock', '$on');
    ref.read(journalUnlockedProvider.notifier).set(false);
  }

  @override
  Widget build(BuildContext context) {
    final s = settingsOf(ref);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NCard(
          gap: 10,
          children: [
            SettingSwitch(
              switchKey: const Key('journal-lock-switch'),
              title: 'Lock journal',
              subtitle:
                  'Asks for your fingerprint, face or screen lock to read it.',
              value: s.journalLock,
              onChanged: _setJournalLock,
            ),
            if (_note != null) Note(_note!, warn: true),
          ],
        ),
        const SizedBox(height: 14),
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
                  : 'Journal, mood, habits and activities are never uploaded. '
                        'No account needed.',
              style: TextStyle(fontSize: 13, color: AppColors.sage900),
            ),
          ],
        ),
      ],
    );
  }
}
