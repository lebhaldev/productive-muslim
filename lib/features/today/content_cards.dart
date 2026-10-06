import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/content/content_models.dart';
import '../../widgets/common.dart';

/// Ayah, hadith and quote cards. Only one is expanded at a time.
class ContentCards extends ConsumerStatefulWidget {
  const ContentCards({super.key});

  @override
  ConsumerState<ContentCards> createState() => _ContentCardsState();
}

class _ContentCardsState extends ConsumerState<ContentCards> {
  String? open;
  bool arabicOnly = false;

  void _toggle(String id) => setState(() => open = open == id ? null : id);

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(dailyContentProvider);
    arabicOnly = settingsOf(ref).arabicOnly;
    return content.when(
      loading: () => const NCard(children: [LinearProgressIndicator()]),
      error: (e, _) =>
          NCard(children: [Text('Daily content could not load: $e')]),
      data: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ayahCard(c.ayah),
          const SizedBox(height: 10),
          _hadithCard(c.hadith),
          const SizedBox(height: 10),
          _quoteCard(c.quote),
        ],
      ),
    );
  }

  Widget _ayahCard(ContentSlot<Ayah> slot) {
    final a = slot.value;
    if (a == null) return _failed('Ayah of the day', slot.error!);
    final fetched = slot.fetchedAt == null
        ? ''
        : DateFormat('d MMM HH:mm').format(slot.fetchedAt!);
    return _ContentCard(
      kicker: 'Ayah of the day',
      open: open == 'ayah',
      onTap: () => _toggle('ayah'),
      arabic: a.arabic,
      text: arabicOnly ? null : a.translation,
      source: a.source,
      // Offline with an earlier day's ayah: say so instead of passing it off
      // as today's (review R3).
      notice: slot.stale && slot.fetchedAt != null
          ? 'Last saved ayah · ${DateFormat('d MMM').format(slot.fetchedAt!)}'
          : null,
      reference: 'Edition: ${a.edition} · fetched $fetched · ${a.sourceUrl}',
    );
  }

  Widget _hadithCard(ContentSlot<Hadith> slot) {
    final h = slot.value;
    if (h == null) return _failed('Hadith of the day', slot.error!);
    return _ContentCard(
      kicker: 'Hadith of the day',
      open: open == 'hadith',
      onTap: () => _toggle('hadith'),
      // Arabic copied verbatim from the same dataset (CR-7).
      arabic: h.arabic,
      arabicSize: 19,
      text: arabicOnly && h.arabic != null ? null : h.text,
      source: h.source,
      reference: [
        h.bookName,
        'English: ${h.translator}',
        ?h.sourceUrl,
      ].join(' · '),
    );
  }

  Widget _quoteCard(ContentSlot<Quote> slot) {
    final q = slot.value;
    if (q == null) return _failed('Quote of the day', slot.error!);
    return _ContentCard(
      kicker: 'Quote of the day',
      open: open == 'quote',
      onTap: () => _toggle('quote'),
      text: '“${q.text}”',
      source: q.attribution,
      tag: 'Encouragement, not scripture',
      reference: q.source,
    );
  }

  Widget _failed(String kicker, String error) => NCard(
    children: [
      Kicker(kicker),
      Text(error, style: meta(size: 13, color: AppColors.neutral800)),
    ],
  );
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.kicker,
    required this.open,
    required this.onTap,
    required this.text,
    required this.source,
    required this.reference,
    this.arabic,
    this.arabicSize = 22,
    this.tag,
    this.notice,
  });

  final String kicker;
  final bool open;
  final VoidCallback onTap;
  final String? arabic;
  final double arabicSize;
  final String? text;
  final String source;
  final String reference;
  final String? tag;
  final String? notice;

  @override
  Widget build(BuildContext context) {
    return NCard(
      onTap: onTap,
      children: [
        Row(
          children: [
            Expanded(child: Kicker(kicker)),
            Text(open ? 'Less' : 'More', style: meta()),
          ],
        ),
        if (arabic != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Text(
              arabic!,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              maxLines: open ? null : 4,
              overflow: open ? null : TextOverflow.ellipsis,
              style: arabicStyle.copyWith(fontSize: arabicSize),
            ),
          ),
        if (text != null)
          Text(
            text!,
            maxLines: open ? null : 4,
            overflow: open ? null : TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        Text(source, style: meta()),
        if (notice != null)
          Text(notice!, style: meta(color: AppColors.accent700)),
        // Expanded: the reference only. No explanations ship until a person
        // has reviewed them (CR-4); none are ever generated in-app.
        if (open) ...[
          if (tag != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Tag(tag!, sage: true),
            ),
          Text(reference, style: meta(size: 11)),
        ],
      ],
    );
  }
}
