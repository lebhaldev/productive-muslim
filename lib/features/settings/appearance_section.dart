import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import 'settings_widgets.dart';
import 'theme_gallery.dart';

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = settingsOf(ref);
    final l = AppLocalizations.of(context);
    return NCard(
      gap: 10,
      children: [
        SettingPicker<AppLanguage>(
          label: l.language,
          value: s.language,
          options: {
            for (final lang in AppLanguage.values)
              lang: lang == AppLanguage.system
                  ? l.languageSystem
                  : reviewedLanguages.contains(lang.code)
                  ? lang.nativeName
                  : '${lang.nativeName} (${tr('preview')})',
          },
          onChanged: (v) => ref.putSetting('language', v.name),
        ),
        const ThemePicker(),
        const SizedBox(height: 4),
        SettingPicker<AppFont>(
          key: const Key('app-font'),
          label: tr('Font'),
          value: s.appFont,
          options: {for (final f in AppFont.values) f: f.label},
          onChanged: (f) => ref.putSetting('appFont', f.name),
        ),
        SettingPicker<ArabicFont>(
          key: const Key('arabic-font'),
          label: tr('Arabic font'),
          value: s.arabicFont,
          options: {for (final f in ArabicFont.values) f: f.label},
          onChanged: (f) => ref.putSetting('arabicFont', f.name),
        ),
        _FontPreview(font: s.appFont, arabic: s.arabicFont),
        SettingPicker<MotionPref>(
          key: const Key('motion-pref'),
          label: tr('Animations'),
          value: MotionPref.parse(s.raw['motion']),
          options: {for (final m in MotionPref.values) m: tr(m.label)},
          onChanged: (m) => ref.putSetting('motion', m.name),
        ),
      ],
    );
  }
}

/// Featured theme cards, the other themes behind "More themes", and
/// System / Light / Dark; used in Settings and on first run. Picking one
/// recolours the whole app at once.
class ThemePicker extends ConsumerStatefulWidget {
  const ThemePicker({super.key});

  @override
  ConsumerState<ThemePicker> createState() => _ThemePickerState();
}

class _ThemePickerState extends ConsumerState<ThemePicker> {
  // Open when the current theme is one of the others, so it stays in view
  // after the app recolours.
  late var _more = !settingsOf(ref).colorTheme.isFeatured;

  @override
  Widget build(BuildContext context) {
    final s = settingsOf(ref);
    void pick(ColorTheme t) => ref.putSetting('colorTheme', t.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(tr('Featured'), style: heading(17)),
        const SizedBox(height: 8),
        FeaturedThemes(selected: s.colorTheme, onPick: pick),
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            key: const Key('more-themes'),
            onPressed: () => setState(() => _more = !_more),
            icon: AnimatedRotation(
              duration: motion(context, Motion.medium),
              turns: _more ? 0.5 : 0,
              child: const Icon(Icons.expand_more),
            ),
            label: Text(tr('More themes')),
          ),
        ),
        AnimatedSize(
          duration: motion(context, Motion.medium),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: !_more
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final t in ColorTheme.values)
                        if (!t.isFeatured)
                          ThemeSwatch(
                            theme: t,
                            selected: s.colorTheme == t,
                            onTap: () => pick(t),
                          ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 8),
        SettingChoice<ThemeMode>(
          key: const Key('theme-mode'),
          value: s.themeMode,
          options: {
            ThemeMode.system: tr('System'),
            ThemeMode.light: tr('Light'),
            ThemeMode.dark: tr('Dark'),
          },
          onChanged: s.colorTheme.alwaysDark
              ? null
              : (m) => ref.putSetting('themeMode', m.name),
        ),
        if (s.colorTheme.alwaysDark) ...[
          const SizedBox(height: 8),
          Note(tr('Night is always dark, for OLED screens.')),
        ],
      ],
    );
  }
}

class ThemeSwatch extends StatelessWidget {
  const ThemeSwatch({
    super.key,
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
      label: tr('{0} colours', [tr(theme.label)]),
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
                  child: Row(
                    // Without stretch the boxes have no height and the
                    // swatch shows empty.
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: ColoredBox(color: p.accent700)),
                      Expanded(child: ColoredBox(color: p.sage600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr(theme.label),
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

/// A line in each chosen font, so the choice is visible before leaving.
class _FontPreview extends StatelessWidget {
  const _FontPreview({required this.font, required this.arabic});
  final AppFont font;
  final ArabicFont arabic;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Tr('Good morning', style: heading(20)),
      Tr(
        'A calm rhythm for every day.',
        style: TextStyle(fontFamily: font.body, fontSize: 15),
      ),
      const SizedBox(height: 4),
      // Sample letters only (the alphabet), never scripture (TR-1).
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          String.fromCharCodes(const [
            0x623,
            0x20,
            0x628,
            0x20,
            0x62A,
            0x20,
            0x62B,
            0x20,
            0x62C,
          ]),
          textDirection: TextDirection.rtl,
          style: arabicStyle.copyWith(fontFamily: arabic.family, fontSize: 24),
        ),
      ),
    ],
  );
}
