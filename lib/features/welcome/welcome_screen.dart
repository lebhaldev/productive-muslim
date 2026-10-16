import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../widgets/common.dart';
import '../settings/location_section.dart';

/// Starter habits offered on first run, in this order.
const starterHabits = [
  "Read Qur'an",
  'Morning adhkar',
  'Evening adhkar',
  'Gratitude note',
  'Call family',
  'Walk',
];

/// First run: location, starter habits, privacy promise. Every step can be
/// skipped; finishing or skipping the last one never shows them again.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  int _step = 0;
  final _picked = <String>{};

  Future<void> _next() async {
    if (_step == 1 && _picked.isNotEmpty) {
      final db = ref.read(databaseProvider);
      for (final h in starterHabits.where(_picked.contains)) {
        await db.addHabit(h);
      }
      _picked.clear();
    }
    if (_step < 2) {
      setState(() => _step++);
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    await ref.read(databaseProvider).putSetting('onboarded', 'true');
    if (mounted) context.go('/today');
  }

  @override
  Widget build(BuildContext context) {
    final (title, sub) = switch (_step) {
      0 => (
        'Where are you?',
        'For prayer times and weather. You can change it later in Settings.',
      ),
      1 => ('Pick a few habits', 'Start small. You can add your own later.'),
      _ => ('Your data stays on this phone', 'No account, no ads.'),
    };
    return Scaffold(
      body: SafeArea(
        child: ScreenBody(
          gap: 16,
          children: [
            Row(
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    margin: const EdgeInsetsDirectional.only(end: 6),
                    width: i == _step ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i <= _step
                          ? AppColors.sage600
                          : AppColors.neutral300,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  key: const Key('welcome-skip-all'),
                  onPressed: _finish,
                  child: const Text('Skip all'),
                ),
              ],
            ),
            Semantics(header: true, child: Text(title, style: heading(26))),
            Text(sub, style: meta(size: 14)),
            if (_step == 0) const LocationSection(),
            if (_step == 1)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final h in starterHabits)
                    FilterChip(
                      key: Key('starter-$h'),
                      label: Text(h),
                      selected: _picked.contains(h),
                      onSelected: (on) => setState(
                        () => on ? _picked.add(h) : _picked.remove(h),
                      ),
                    ),
                ],
              ),
            if (_step == 2)
              const NCard(
                gap: 8,
                children: [
                  Text(
                    'Habits, moods, journal, duas and prayer logs are kept '
                    'only on this phone.',
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                  Text(
                    'They leave it only if you export a backup or turn on '
                    'Google Drive backup in Settings.',
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            Row(
              children: [
                if (_step < 2)
                  TextButton(
                    key: const Key('welcome-skip'),
                    onPressed: () => setState(() {
                      _picked.clear();
                      _step++;
                    }),
                    child: const Text('Skip'),
                  ),
                const Spacer(),
                FilledButton(
                  key: const Key('welcome-next'),
                  onPressed: _next,
                  child: Text(_step < 2 ? 'Next' : 'Start'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
