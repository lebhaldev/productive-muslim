import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import 'settings_widgets.dart';

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = settingsOf(ref);
    return NCard(
      gap: 10,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final t in ColorTheme.values)
              _ThemeSwatch(
                theme: t,
                selected: s.colorTheme == t,
                onTap: () => ref.putSetting('colorTheme', t.name),
              ),
          ],
        ),
        SettingChoice<ThemeMode>(
          key: const Key('theme-mode'),
          value: s.themeMode,
          options: const {
            ThemeMode.system: 'System',
            ThemeMode.light: 'Light',
            ThemeMode.dark: 'Dark',
          },
          onChanged: s.colorTheme.alwaysDark
              ? null
              : (m) => ref.putSetting('themeMode', m.name),
        ),
        if (s.colorTheme.alwaysDark)
          const Note('Night is always dark, for OLED screens.'),
        const SizedBox(height: 4),
        SettingPicker<AppFont>(
          key: const Key('app-font'),
          label: 'Font',
          value: s.appFont,
          options: {for (final f in AppFont.values) f: f.label},
          onChanged: (f) => ref.putSetting('appFont', f.name),
        ),
        SettingPicker<ArabicFont>(
          key: const Key('arabic-font'),
          label: 'Arabic font',
          value: s.arabicFont,
          options: {for (final f in ArabicFont.values) f: f.label},
          onChanged: (f) => ref.putSetting('arabicFont', f.name),
        ),
        _FontPreview(font: s.appFont, arabic: s.arabicFont),
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
                  child: Row(
                    children: [
                      Expanded(child: ColoredBox(color: p.accent700)),
                      Expanded(child: ColoredBox(color: p.sage600)),
                    ],
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

/// A line in each chosen font, so the choice is visible before leaving.
class _FontPreview extends StatelessWidget {
  const _FontPreview({required this.font, required this.arabic});
  final AppFont font;
  final ArabicFont arabic;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Good morning', style: heading(20)),
      Text(
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
