import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/copy.dart';
import '../../core/day_key.dart';
import '../../data/db/database.dart' show gratitudeLines;
import '../../widgets/common.dart';
import '../../widgets/locked_view.dart';

/// One entry per day, autosaved on this phone (FR-3).
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _gratitude = List.generate(3, (_) => TextEditingController());
  String? _loadedDay;
  DateTime? _savedAt;
  Timer? _debounce;
  late final _db = ref.read(databaseProvider);
  late final _clock = ref.read(clockProvider);

  @override
  void initState() {
    super.initState();
    // Resolve before dispose, where ref can no longer be used.
    _db;
    _clock;
  }

  @override
  void dispose() {
    _flush();
    _title.dispose();
    _body.dispose();
    for (final g in _gratitude) {
      g.dispose();
    }
    super.dispose();
  }

  void _load(String day) {
    _flush();
    final j = ref.read(journalsProvider).value?[day];
    _title.text = j?.title ?? '';
    _body.text = j?.body ?? '';
    final lines = gratitudeLines(j);
    for (var i = 0; i < 3; i++) {
      _gratitude[i].text = i < lines.length ? lines[i] : '';
    }
    _savedAt = j?.updatedAt;
    _loadedDay = day;
  }

  void _changed() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _save);
    setState(() {});
  }

  void _flush() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      _save();
    }
  }

  Future<void> _save() async {
    final day = _loadedDay;
    if (day == null) return;
    final now = _clock.now();
    await _db.saveJournal(
      day,
      _title.text.trim(),
      _body.text,
      now,
      gratitude: [for (final g in _gratitude) g.text],
    );
    if (mounted) setState(() => _savedAt = _isEmpty ? null : now);
  }

  bool get _isEmpty =>
      _body.text.trim().isEmpty &&
      _gratitude.every((g) => g.text.trim().isEmpty);

  @override
  Widget build(BuildContext context) {
    if (ref.watch(journalLockedProvider)) {
      return const LockedView(
        title: 'Your journal is locked',
        reason: 'Unlock your Nurday journal',
        unlockKey: Key('unlock-journal'),
      );
    }
    final today = watchToday(ref);
    final sel = ref.watch(selectedDayProvider);
    // Wait for stored entries before filling the fields.
    final journals = ref.watch(journalsProvider);
    if (journals.hasValue && _loadedDay != sel) _load(sel);

    final status = _isEmpty
        ? 'Write something to save this day’s entry.'
        : 'Saved on this phone${_savedAt == null ? '' : ' · ${DateFormat('HH:mm').format(_savedAt!)}'}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      children: [
        Row(
          children: [
            RoundIconButton(
              icon: Icons.chevron_left,
              label: 'Previous day',
              onPressed: () =>
                  ref.read(selectedDayProvider.notifier).set(shiftDay(sel, -1)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Journal', style: meta(size: 13)),
                  Semantics(
                    container: true,
                    header: true,
                    child: Text(
                      DateFormat('EEE d MMMM').format(parseDayKey(sel)),
                      style: heading(22),
                    ),
                  ),
                ],
              ),
            ),
            RoundIconButton(
              icon: Icons.chevron_right,
              label: 'Next day',
              onPressed: sel.compareTo(today) < 0
                  ? () => ref
                        .read(selectedDayProvider.notifier)
                        .set(shiftDay(sel, 1))
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('journal-title'),
          controller: _title,
          onChanged: (_) => _changed(),
          style: heading(16),
          decoration: const InputDecoration(hintText: 'Title (optional)'),
        ),
        const SizedBox(height: 16),
        const Kicker('Gratitude'),
        const SizedBox(height: 4),
        for (var i = 0; i < 3; i++)
          TextField(
            key: Key('gratitude-$i'),
            controller: _gratitude[i],
            onChanged: (_) => _changed(),
            textCapitalization: TextCapitalization.sentences,
            maxLength: 120,
            decoration: InputDecoration(
              prefixText: '${i + 1}.  ',
              hintText: 'Optional',
              counterText: '',
            ),
          ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('journal-body'),
          controller: _body,
          onChanged: (_) => _changed(),
          minLines: 8,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 16, height: 1.6),
          decoration: InputDecoration(
            // Rotates daily through fixed prompts (FR-19).
            hintText: journalPromptFor(sel),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              borderSide: BorderSide(color: AppColors.divider),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(status, style: meta()),
      ],
    );
  }
}

/// The day's body placeholder: the fixed prompts in turn, by day key.
String journalPromptFor(String day) {
  final d = parseDayKey(day);
  final n =
      DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;
  return journalPrompts[n % journalPrompts.length];
}
