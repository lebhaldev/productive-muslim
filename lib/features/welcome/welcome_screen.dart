import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../widgets/common.dart';
import '../settings/appearance_section.dart';
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
  const WelcomeScreen({super.key, this.themeOnly = false});

  /// Only the colour step, for phones set up before it existed.
  final bool themeOnly;

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  int _step = 0;
  final _picked = <String>{};

  static const _steps = 4;
  int get _last => widget.themeOnly ? 0 : _steps - 1;

  Future<void> _next() async {
    if (_step == 2 && _picked.isNotEmpty) {
      final db = ref.read(databaseProvider);
      for (final h in starterHabits.where(_picked.contains)) {
        await db.addHabit(h);
      }
      _picked.clear();
    }
    if (_step < _last) {
      setState(() => _step++);
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    final db = ref.read(databaseProvider);
    await db.putSetting('themePicked', 'true');
    await db.putSetting('onboarded', 'true');
    if (mounted) context.go('/today');
  }

  @override
  Widget build(BuildContext context) {
    final (title, sub) = switch (_step) {
      0 => ('Pick your colours', 'You can change them any time in Settings.'),
      1 => (
        'Where are you?',
        'For prayer times and weather. You can change it later in Settings.',
      ),
      2 => ('Pick a few habits', 'Start small. You can add your own later.'),
      _ => ('Your data stays on this phone', 'No account, no ads.'),
    };
    return Scaffold(
      body: SafeArea(
        child: ScreenBody(
          gap: 16,
          children: [
            Row(
              children: [
                for (var i = 0; i <= _last; i++)
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
                  child: Text(widget.themeOnly ? 'Skip' : 'Skip all'),
                ),
              ],
            ),
            Semantics(header: true, child: Text(title, style: heading(26))),
            Text(sub, style: meta(size: 14)),
            if (_step == 0) ...[const ThemePicker(), const ThemePreview()],
            if (_step == 1) const LocationSection(),
            if (_step == 2)
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
            if (_step == 3)
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
                if (_step < _last)
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
                  child: Text(
                    _step < _last
                        ? 'Next'
                        : widget.themeOnly
                        ? 'Done'
                        : 'Start',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A small sample of Today in the picked colours.
class ThemePreview extends StatelessWidget {
  const ThemePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return NCard(
      key: const Key('theme-preview'),
      gap: 10,
      children: [
        const Kicker('Preview'),
        Text('Good morning', style: heading(22)),
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.sage600,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, size: 16, color: AppColors.bg),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Text('Morning walk')),
            const Flexible(child: Tag('3 of the last 7 days')),
          ],
        ),
        Row(
          children: [
            for (final c in AppColors.current.moods)
              Expanded(
                child: Container(
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
          ],
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton(onPressed: () {}, child: const Text('Add')),
        ),
      ],
    );
  }
}
