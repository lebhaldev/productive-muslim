import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
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

enum _Step { location, habits, colours, privacy }

/// First run: location, starter habits, colours, privacy promise. Every step
/// can be skipped; finishing or skipping the last one never shows them again.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key, this.themeOnly = false});

  /// Only the colour step, for phones set up before it existed.
  final bool themeOnly;

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  int _index = 0;
  final _picked = <String>{};

  List<_Step> get _steps =>
      widget.themeOnly ? const [_Step.colours] : _Step.values;
  _Step get _step => _steps[_index];
  bool get _isLast => _index == _steps.length - 1;

  Future<void> _next() async {
    if (_step == _Step.habits && _picked.isNotEmpty) {
      final db = ref.read(databaseProvider);
      for (final h in starterHabits.where(_picked.contains)) {
        await db.addHabit(h);
      }
      _picked.clear();
    }
    await _advance();
  }

  Future<void> _advance() async {
    if (_isLast) return _finish();
    setState(() {
      _picked.clear();
      _index++;
    });
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
      _Step.location => (
        'Where are you?',
        'For prayer times and weather. Stays on this phone.',
      ),
      _Step.habits => (
        'Pick a few habits',
        'Start small. You can change these anytime.',
      ),
      _Step.colours => (
        'Pick your colours',
        'You can change them any time in Settings.',
      ),
      _Step.privacy => ('Your data stays on this phone.', 'No account, no ads.'),
    };
    final action = switch (_step) {
      _ when widget.themeOnly => 'Done',
      _Step.habits when _picked.isNotEmpty =>
        _picked.length == 1 ? 'Add 1 habit' : 'Add ${_picked.length} habits',
      _Step.privacy => 'Start my day',
      _ => 'Continue',
    };
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 8, 0),
              child: Row(
                children: [
                  for (var i = 0; i < _steps.length; i++)
                    AnimatedContainer(
                      duration: motion(context, Motion.quick),
                      margin: const EdgeInsetsDirectional.only(end: 6),
                      width: i == _index ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i <= _index
                            ? AppColors.sage600
                            : AppColors.neutral300,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                  const SizedBox(width: 4),
                  if (_steps.length > 1)
                    Flexible(
                      child: Text(
                        'Step ${_index + 1} of ${_steps.length}',
                        style: meta(size: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    key: const Key('welcome-skip'),
                    onPressed: _advance,
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ScreenBody(
                key: ValueKey(_step),
                gap: 16,
                children: [
                  if (_step == _Step.privacy)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.sage200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.smartphone_outlined,
                          size: 34,
                          color: AppColors.sage900,
                        ),
                      ),
                    ),
                  Semantics(
                    header: true,
                    child: Text(title, style: heading(26)),
                  ),
                  Text(sub, style: meta(size: 14)),
                  if (_step == _Step.colours) ...[
                    const ThemePicker(),
                    const ThemePreview(),
                  ],
                  if (_step == _Step.location) const LocationSection(),
                  if (_step == _Step.habits)
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
                  if (_step == _Step.privacy)
                    const NCard(
                      gap: 8,
                      children: [
                        Text(
                          'Habits, moods, journal, duas and prayer logs are '
                          'kept only on this phone.',
                          style: TextStyle(fontSize: 15, height: 1.5),
                        ),
                        Text(
                          'They leave it only if you export a backup or turn '
                          'on Google Drive backup in Settings.',
                          style: TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('welcome-next'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: _next,
                  child: Text(action),
                ),
              ),
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
            const Expanded(child: Text('Morning adhkar')),
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
          child: FilledButton(
            onPressed: () {},
            child: const Text("Write today's journal"),
          ),
        ),
      ],
    );
  }
}
