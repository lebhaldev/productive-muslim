import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/common.dart';
import 'about_section.dart';
import 'appearance_section.dart';
import 'backup_section.dart';
import 'content_section.dart';
import 'location_section.dart';
import 'prayer_section.dart';
import 'privacy_section.dart';
import 'reminders_section.dart';

typedef SettingsSectionInfo = ({
  String id,
  String title,
  String sub,
  IconData icon,
  Widget Function() build,
});

/// Settings sections, listed on the Settings menu in this order.
final List<SettingsSectionInfo> settingsSections = [
  (
    id: 'location',
    title: 'Location & weather',
    sub: 'City, location, temperature unit',
    icon: Icons.place_outlined,
    build: () => const LocationSection(),
  ),
  (
    id: 'appearance',
    title: 'Appearance',
    sub: 'Colour theme, light or dark',
    icon: Icons.palette_outlined,
    build: () => const AppearanceSection(),
  ),
  (
    id: 'prayer',
    title: 'Prayer',
    sub: 'Calculation method, Asr, notifications',
    icon: Icons.access_time,
    build: () => const PrayerSection(),
  ),
  (
    id: 'content',
    title: 'Daily content',
    sub: 'Faith cards, translation, language',
    icon: Icons.menu_book_outlined,
    build: () => const ContentSection(),
  ),
  (
    id: 'reminders',
    title: 'Reminders',
    sub: 'Daily reminder time',
    icon: Icons.notifications_none,
    build: () => const RemindersSection(),
  ),
  (
    id: 'privacy',
    title: 'Privacy',
    sub: 'Journal lock, where your data lives',
    icon: Icons.lock_outline,
    build: () => const PrivacySection(),
  ),
  (
    id: 'backup',
    title: 'Backup',
    sub: 'Export, import, Google Drive',
    icon: Icons.cloud_outlined,
    build: () => const BackupSection(),
  ),
  (
    id: 'about',
    title: 'Sources & licenses',
    sub: 'Where the ayah, hadith, tafsir and quotes come from',
    icon: Icons.info_outline,
    build: () => const AboutSection(),
  ),
];

/// Settings, outside the tabs: the menu, or one section when [section] is
/// set. Opened from the gear on Today.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.section});
  final String? section;

  @override
  Widget build(BuildContext context) {
    final match = settingsSections.where((x) => x.id == section);
    return Scaffold(
      body: SafeArea(
        child: match.isEmpty
            ? const _SettingsMenu()
            : ScreenBody(
                children: [
                  SubScreenTitle(
                    match.first.title,
                    backTooltip: 'Back to Settings',
                    onBack: () => context.go('/settings'),
                  ),
                  match.first.build(),
                ],
              ),
      ),
    );
  }
}

class _SettingsMenu extends StatelessWidget {
  const _SettingsMenu();

  @override
  Widget build(BuildContext context) => ScreenBody(
    gap: 10,
    children: [
      SubScreenTitle(
        'Settings',
        backTooltip: 'Back',
        onBack: () => context.canPop() ? context.pop() : context.go('/today'),
      ),
      for (final x in settingsSections)
        NavRow(
          key: Key('settings-${x.id}'),
          icon: x.icon,
          title: x.title,
          sub: x.sub,
          onTap: () => context.go('/settings/${x.id}'),
        ),
    ],
  );
}
