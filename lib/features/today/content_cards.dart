import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/content/content_models.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';

enum _Kind {
  ayah('Ayah'),
  hadith('Hadith'),
  quote('Quote');

  const _Kind(this.label);
  final String label;
}

/// The day's ayah, hadith and quote, each in its own card so all three
/// are readable at a glance. Tap a card to open its explanation and
/// source; "Show another" moves to the next item of that kind for today.
class ContentCards extends ConsumerStatefulWidget {
  const ContentCards({super.key});

  @override
  ConsumerState<ContentCards> createState() => _ContentCardsState();
}

class _ContentCardsState extends ConsumerState<ContentCards> {
  final _open = <_Kind>{};

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(dailyContentProvider);
    final arabicOnly = settingsOf(ref).arabicOnly;
    return content.when(
      skipLoadingOnReload: true,
      loading: () => const NCard(children: [LinearProgressIndicator()]),
      error: (e, _) =>
          NCard(children: [Text('Daily content could not load: $e')]),
      data: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, k) in _Kind.values.indexed) ...[
            if (i > 0) const SizedBox(height: 10),
            _card(k, c, arabicOnly),
          ],
        ],
      ),
    );
  }

  Widget _card(_Kind kind, DailyContent c, bool arabicOnly) {
    final open = _open.contains(kind);
    return NCard(
      key: Key('content-card-${kind.name}'),
      onTap: () => setState(() => open ? _open.remove(kind) : _open.add(kind)),
      animateSize: true,
      children: [
        Row(
          children: [
            Expanded(child: Kicker('${kind.label} of the day')),
            IconButton(
              key: Key('content-next-${kind.name}'),
              tooltip: 'Show another ${kind.label.toLowerCase()}',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.autorenew, color: AppColors.neutral700),
              onPressed: () {
                setState(() => _open.remove(kind));
                ref
                    .read(contentOffsetsProvider.notifier)
                    .next(watchToday(ref), kind.name);
              },
            ),
          ],
        ),
        AnimatedSwitcher(
          duration: motion(context, Motion.medium),
          child: KeyedSubtree(
            key: ValueKey(
              '${kind.name}|${switch (kind) {
                _Kind.ayah => c.ayah.value?.ref,
                _Kind.hadith => c.hadith.value?.source,
                _Kind.quote => c.quote.value?.arabic.hashCode,
              }}',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: switch (kind) {
                _Kind.ayah => _ayah(c.ayah, arabicOnly, open),
                _Kind.hadith => _hadith(c.hadith, arabicOnly, open),
                _Kind.quote => _quote(c.quote, open),
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _ayah(ContentSlot<Ayah> slot, bool arabicOnly, bool open) {
    final a = slot.value;
    if (a == null) return [_error(slot.error!)];
    final fetched = slot.fetchedAt == null
        ? ''
        : DateFormat('d MMM HH:mm').format(slot.fetchedAt!);
    final tafsir = open ? ref.watch(tafsirProvider(a.ref)).value : null;
    return [
      ArabicBlock(a.arabic, size: 22, maxLines: open ? null : 4),
      if (!arabicOnly) ..._gap(_body(a.translation, open: open)),
      ..._gap(Text(a.source, style: meta())),
      // Offline with an earlier day's ayah: say so instead of passing it off
      // as today's (review R3).
      if (slot.stale && slot.fetchedAt != null)
        ..._gap(
          Text(
            'Last saved ayah · ${DateFormat('d MMM').format(slot.fetchedAt!)}',
            style: meta(color: AppColors.accent700),
          ),
        ),
      if (!open) ..._gap(_hint('Tap for tafsir')),
      if (open) ...[
        if (tafsir != null) ...[
          ..._gap(const Divider(height: 8)),
          ..._gap(const Kicker('Tafsir')),
          ..._gap(
            Text(
              tafsir.arabic,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: arabicStyle.copyWith(fontSize: 17, height: 1.8),
            ),
          ),
          ..._gap(Text(tafsir.arabicSource, style: meta(size: 11))),
          if (!arabicOnly) ...[
            ..._gap(_body(tafsir.english, open: open)),
            ..._gap(Text(tafsir.englishSource, style: meta(size: 11))),
          ],
        ] else
          ..._gap(Text('No tafsir is bundled for this ayah.', style: meta())),
        ..._gap(
          Text(
            'Edition: ${a.edition} · fetched $fetched · ${a.sourceUrl}',
            style: meta(size: 11),
          ),
        ),
      ],
    ];
  }

  List<Widget> _hadith(ContentSlot<Hadith> slot, bool arabicOnly, bool open) {
    final h = slot.value;
    if (h == null) return [_error(slot.error!)];
    return [
      // Arabic copied verbatim from the same dataset (CR-7).
      if (h.arabic != null)
        ArabicBlock(h.arabic!, size: 19, maxLines: open ? null : 4),
      if (!(arabicOnly && h.arabic != null))
        ..._gap(_body(h.text, open: open), first: h.arabic == null),
      ..._gap(Text(h.source, style: meta())),
      if (!open) ..._gap(_hint('Tap for source')),
      if (open) ...[
        // No reviewed explanation exists for this dataset yet; none is
        // ever written by the app (CR-1, CR-4).
        ..._gap(
          Text(
            'No reviewed explanation is available for this hadith yet.',
            style: meta(),
          ),
        ),
        ..._gap(
          Text(
            [h.bookName, 'English: ${h.translator}', ?h.sourceUrl].join(' · '),
            style: meta(size: 11),
          ),
        ),
      ],
    ];
  }

  List<Widget> _quote(ContentSlot<Quote> slot, bool open) {
    final q = slot.value;
    if (q == null) return [_error(slot.error!)];
    return [
      // Arabic only: there is no translation we may show (CR-7).
      ArabicBlock(q.arabic, size: 19, maxLines: open ? null : 4),
      ..._gap(Text('${q.attribution} · ${q.work}', style: meta())),
      if (open) ...[
        ..._gap(
          const Align(
            alignment: Alignment.centerLeft,
            child: Tag('Encouragement, not scripture', sage: true),
          ),
        ),
        ..._gap(
          Text(
            ['OpenITI corpus', ?q.locator, ?q.sourceUrl].join(' · '),
            style: meta(size: 11),
          ),
        ),
      ],
    ];
  }

  List<Widget> _gap(Widget w, {bool first = false}) => [
    if (!first) const SizedBox(height: 8),
    w,
  ];

  Widget _body(String text, {required bool open}) => Text(
    text,
    maxLines: open ? null : 4,
    overflow: open ? null : TextOverflow.ellipsis,
    style: const TextStyle(fontSize: 15, height: 1.5),
  );

  Widget _hint(String text) => Text(text, style: meta(size: 11));

  Widget _error(String error) =>
      Text(error, style: meta(size: 13, color: AppColors.neutral800));
}
