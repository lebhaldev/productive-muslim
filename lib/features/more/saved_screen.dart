import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/db/database.dart';
import '../../widgets/common.dart';
import 'more_screen.dart';

/// Ayat and hadith saved from the Today cards, with their references.
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(bookmarksProvider).value ?? const <Bookmark>[];
    final hadith = ref.watch(hadithByIdProvider).value ?? const {};
    return ScreenBody(
      gap: 10,
      children: [
        const MoreTitle('Saved'),
        if (saved.isEmpty)
          Text(
            'Tap the bookmark on an ayah or hadith card to keep it here.',
            style: meta(size: 13),
          ),
        for (final b in saved)
          NCard(
            key: Key('saved-${b.kind}-${b.ref}'),
            gap: 8,
            children: [
              Row(
                children: [
                  Expanded(child: Kicker(b.kind == 'ayah' ? 'Ayah' : 'Hadith')),
                  IconButton(
                    tooltip: 'Remove from Saved',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.bookmark, color: AppColors.sage600),
                    onPressed: () => ref
                        .read(databaseProvider)
                        .toggleBookmark(
                          b.kind,
                          b.ref,
                          ref.read(clockProvider).now(),
                        ),
                  ),
                ],
              ),
              ...switch ((b.kind, hadith[b.ref])) {
                // Hadith text is bundled, so it shows verbatim offline.
                ('hadith', final h?) => [
                  if (h.arabic != null)
                    ArabicBlock(h.arabic!, size: 18, maxLines: 3),
                  Text(
                    h.text,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  Text('${h.source} · ${h.translator}', style: meta()),
                ],
                ('ayah', _) => [Text("Qur'an ${b.ref}", style: heading(17))],
                _ => [Text(b.ref, style: meta())],
              },
            ],
          ),
      ],
    );
  }
}
