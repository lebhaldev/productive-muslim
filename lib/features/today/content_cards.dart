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

/// The day's ayah, hadith and quote in one card, one at a time, so Today
/// stays calm. Tap to open the explanation and source; "Show another"
/// moves to the next item of that kind for today.
class ContentCards extends ConsumerStatefulWidget {
  const ContentCards({super.key});

  @override
  ConsumerState<ContentCards> createState() => _ContentCardsState();
}

class _ContentCardsState extends ConsumerState<ContentCards> {
  _Kind kind = _Kind.ayah;
  bool open = false;

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(dailyContentProvider);
    final arabicOnly = settingsOf(ref).arabicOnly;
    return content.when(
      skipLoadingOnReload: true,
      loading: () => const NCard(children: [LinearProgressIndicator()]),
      error: (e, _) =>
          NCard(children: [Text('Daily content could not load: $e')]),
      data: (c) => NCard(
        onTap: () => setState(() => open = !open),
        animateSize: true,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final k in _Kind.values)
                      _KindTab(
                        kind: k,
                        selected: kind == k,
                        onTap: () => setState(() {
                          kind = k;
                          open = false;
                        }),
                      ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('content-next'),
                tooltip: 'Show another ${kind.label.toLowerCase()}',
                icon: Icon(Icons.autorenew, color: AppColors.neutral700),
                onPressed: () {
                  setState(() => open = false);
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
                  _Kind.ayah => _ayah(c.ayah, arabicOnly),
                  _Kind.hadith => _hadith(c.hadith, arabicOnly),
                  _Kind.quote => _quote(c.quote),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _ayah(ContentSlot<Ayah> slot, bool arabicOnly) {
    final a = slot.value;
    if (a == null) return [_error(slot.error!)];
    final fetched = slot.fetchedAt == null
        ? ''
        : DateFormat('d MMM HH:mm').format(slot.fetchedAt!);
    final tafsir = open ? ref.watch(tafsirProvider(a.ref)).value : null;
    return [
      ArabicBlock(a.arabic, size: 22, maxLines: open ? null : 4),
      if (!arabicOnly) ..._gap(_body(a.translation)),
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
            ..._gap(_body(tafsir.english)),
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

  List<Widget> _hadith(ContentSlot<Hadith> slot, bool arabicOnly) {
    final h = slot.value;
    if (h == null) return [_error(slot.error!)];
    return [
      // Arabic copied verbatim from the same dataset (CR-7).
      if (h.arabic != null)
        ArabicBlock(h.arabic!, size: 19, maxLines: open ? null : 4),
      if (!(arabicOnly && h.arabic != null))
        ..._gap(
          _body(h.text, maxLines: open ? null : 4),
          first: h.arabic == null,
        ),
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

  List<Widget> _quote(ContentSlot<Quote> slot) {
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

  Widget _body(String text, {int? maxLines}) => Text(
    text,
    maxLines: open ? null : (maxLines ?? 4),
    overflow: open ? null : TextOverflow.ellipsis,
    style: const TextStyle(fontSize: 15, height: 1.5),
  );

  Widget _hint(String text) => Text(text, style: meta(size: 11));

  Widget _error(String error) =>
      Text(error, style: meta(size: 13, color: AppColors.neutral800));
}

class _KindTab extends StatelessWidget {
  const _KindTab({
    required this.kind,
    required this.selected,
    required this.onTap,
  });
  final _Kind kind;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: kind.label,
      excludeSemantics: true,
      child: InkWell(
        key: Key('content-tab-${kind.name}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: AnimatedContainer(
          duration: motion(context, Motion.quick),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.sage300 : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected ? AppColors.sage300 : AppColors.divider,
            ),
          ),
          child: Text(
            kind.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
