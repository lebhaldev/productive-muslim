import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/day_key.dart';
import '../../widgets/common.dart';

/// One entry per day, autosaved on this phone (FR-3).
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
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
    super.dispose();
  }

  void _load(String day) {
    _flush();
    final j = ref.read(journalsProvider).value?[day];
    _title.text = j?.title ?? '';
    _body.text = j?.body ?? '';
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
    await _db.saveJournal(day, _title.text.trim(), _body.text, now);
    if (mounted) {
      setState(() => _savedAt = _body.text.trim().isEmpty ? null : now);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = watchToday(ref);
    final sel = ref.watch(selectedDayProvider);
    // Wait for stored entries before filling the fields.
    final journals = ref.watch(journalsProvider);
    if (journals.hasValue && _loadedDay != sel) _load(sel);

    final status = _body.text.trim().isEmpty
        ? 'Write something to save this day’s entry.'
        : 'Saved on this phone${_savedAt == null ? '' : ' · ${DateFormat('HH:mm').format(_savedAt!)}'}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              RoundIconButton(
                icon: Icons.chevron_left,
                label: 'Previous day',
                onPressed: () => ref
                    .read(selectedDayProvider.notifier)
                    .set(shiftDay(sel, -1)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Journal', style: meta(size: 13)),
                    Semantics(
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
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              key: const Key('journal-body'),
              controller: _body,
              onChanged: (_) => _changed(),
              expands: true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 16, height: 1.6),
              decoration: InputDecoration(
                hintText: 'What happened today? What are you grateful for?',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(status, style: meta()),
        ],
      ),
    );
  }
}
