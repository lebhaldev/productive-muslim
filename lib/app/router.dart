import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/day_key.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/habits/habits_screen.dart';
import '../features/journal/journal_screen.dart';
import '../features/more/activities_screen.dart';
import '../features/more/more_screen.dart';
import '../features/more/reflect_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/prayer/prayer_screen.dart';
import '../features/today/today_screen.dart';
import 'providers.dart';
import 'theme.dart';
import '../widgets/motion.dart';

GoRouter buildRouter() => GoRouter(
  initialLocation: '/today',
  routes: [
    // Settings sit outside the tabs, as their own full-screen menu.
    GoRoute(
      path: '/settings',
      builder: (_, _) => const SettingsPage(),
      routes: [
        GoRoute(
          path: ':section',
          builder: (_, state) =>
              SettingsPage(section: state.pathParameters['section']),
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/today', builder: (_, _) => const TodayScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/habits', builder: (_, _) => const HabitsScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (_, _) => const CalendarScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/journal', builder: (_, _) => const JournalScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              builder: (_, _) => const MoreScreen(),
              routes: [
                GoRoute(
                  path: 'prayer',
                  builder: (_, _) => const PrayerScreen(),
                ),
                GoRoute(
                  path: 'activities',
                  builder: (_, _) => const ActivitiesScreen(),
                ),
                GoRoute(
                  path: 'reflect',
                  builder: (_, _) => const ReflectScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Opens the Journal on [day] (Today shortcut, Calendar "Open journal").
void openJournal(BuildContext context, WidgetRef ref, String day) {
  ref.read(selectedDayProvider.notifier).set(day);
  context.go('/journal');
}

class _Tab {
  const _Tab(this.label, this.icon);
  final String label;
  final IconData icon;
}

const _tabs = [
  _Tab('Today', Icons.wb_sunny_outlined),
  _Tab('Habits', Icons.check),
  _Tab('Calendar', Icons.grid_view),
  _Tab('Journal', Icons.edit_outlined),
  _Tab('More', Icons.more_horiz),
];

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: FadeOnChange(trigger: shell.currentIndex, child: shell),
      ),
      // Nav labels scale up to 1.4x; larger sizes would push five tabs off
      // screen, and each tab still has its spoken label.
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.4,
        child: Container(
          color: AppColors.surface,
          padding: EdgeInsets.fromLTRB(
            6,
            8,
            6,
            8 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _NavButton(
                    tab: _tabs[i],
                    selected: shell.currentIndex == i,
                    onTap: () {
                      // Journal tab always opens on today, as in the design.
                      if (i == 3) {
                        ref
                            .read(selectedDayProvider.notifier)
                            .set(dayKey(ref.read(clockProvider).now()));
                      }
                      shell.goBranch(
                        i,
                        initialLocation: i == shell.currentIndex,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });
  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      child: InkWell(
        key: Key('tab-${tab.label}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.sage300 : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Icon(tab.icon, size: 20, color: AppColors.text),
              ),
              const SizedBox(height: 4),
              Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
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
