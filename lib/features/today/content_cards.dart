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

  void _toggle(String id) => setState(() => open = open == id ? null : id);

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(dailyContentProvider);
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
    return _ContentCard(
      kicker: 'Ayah of the day',
      open: open == 'ayah',
      onTap: () => _toggle('ayah'),
      arabic: a.arabic,
      text: a.translation,
      source: a.source,
      noteLabel: 'App summary — not tafsir',
      reference:
          'Edition: ${a.edition} · fetched '
          '${slot.fetchedAt == null ? '' : DateFormat('d MMM HH:mm').format(slot.fetchedAt!)}'
          '${slot.stale ? ' · offline, showing last saved ayah' : ''}',
    );
  }

  Widget _hadithCard(ContentSlot<Hadith> slot) {
    final h = slot.value;
    if (h == null) return _failed('Hadith of the day', slot.error!);
    return _ContentCard(
      kicker: 'Hadith of the day',
      open: open == 'hadith',
      onTap: () => _toggle('hadith'),
      text: h.text,
      source: h.source,
      noteLabel: 'App summary',
      reference: '${h.bookName} · Grading: ${h.grade} · ${h.sourceUrl}',
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
      noteLabel: 'Encouragement, not scripture',
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
    required this.noteLabel,
    required this.reference,
    this.arabic,
  });

  final String kicker;
  final bool open;
  final VoidCallback onTap;
  final String? arabic;
  final String text;
  final String source;
  final String noteLabel;
  final String reference;

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
              style: arabicStyle,
            ),
          ),
        Text(
          text,
          maxLines: open ? null : 4,
          overflow: open ? null : TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        Text(source, style: meta()),
        if (open) ...[
          // No reviewed explanations ship yet, so only the label and the
          // reference are shown (CR-4). Notes are never generated in-app.
          Align(
            alignment: Alignment.centerLeft,
            child: Tag(noteLabel, sage: true),
          ),
          Text(
            noteLabel.startsWith('App summary')
                ? 'No summary has been reviewed for this item yet.'
                : 'From the bundled quote list.',
            style: const TextStyle(fontSize: 13, color: AppColors.neutral800),
          ),
          Text(reference, style: meta(size: 11)),
        ],
      ],
    );
  }
}
