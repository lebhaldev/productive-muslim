import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/day_key.dart';
import '../../data/db/database.dart';
import '../../widgets/common.dart';
import 'more_screen.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  final _title = TextEditingController();
  final _note = TextEditingController();
  final _duration = TextEditingController(text: '30');
  late TimeOfDay _time = TimeOfDay.fromDateTime(ref.read(clockProvider).now());
  Activity? _editing;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _duration.dispose();
    super.dispose();
  }

  void _edit(Activity a) => setState(() {
    _editing = a;
    _title.text = a.title;
    _note.text = a.note ?? '';
    _duration.text = '${a.durationMinutes}';
    _time = parseHhmm(a.startTime);
  });

  void _reset() => setState(() {
    _editing = null;
    _title.clear();
    _note.clear();
    _duration.text = '30';
    _time = TimeOfDay.fromDateTime(ref.read(clockProvider).now());
  });

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final minutes = (int.tryParse(_duration.text) ?? 1).clamp(1, 24 * 60);
    final note = _note.text.trim();
    await ref
        .read(databaseProvider)
        .saveActivity(
          ActivitiesCompanion(
            id: _editing == null ? const Value.absent() : Value(_editing!.id),
            title: Value(title),
            note: Value(note.isEmpty ? null : note),
            startTime: Value(hhmm(_time)),
            durationMinutes: Value(minutes),
            // New entries are logged for today; edits keep their date (OQ-19).
            dayKey: Value(_editing?.dayKey ?? watchTodayRead()),
          ),
        );
    _reset();
  }

  String watchTodayRead() => dayKey(ref.read(clockProvider).now());

  @override
  Widget build(BuildContext context) {
    final today = watchToday(ref);
    final acts = ref.watch(activitiesProvider).value ?? const <Activity>[];
    final groups = <String, List<Activity>>{};
    for (final a in acts) {
      (groups[a.dayKey] ??= []).add(a);
    }
    final days = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    String dayLabel(String k) {
      if (k == today) return 'Today';
      if (k == shiftDay(today, -1)) return 'Yesterday';
      return DateFormat('EEEE d MMM').format(parseDayKey(k));
    }

    return ScreenBody(
      children: [
        const MoreTitle('Activities'),
        NCard(
          children: [
            TextField(
              key: const Key('activity-title'),
              controller: _title,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'What did you do?'),
            ),
            TextField(
              controller: _note,
              decoration: const InputDecoration(hintText: 'Note (optional)'),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: _time,
                      );
                      if (t != null) setState(() => _time = t);
                    },
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text('Start ${hhmm(_time)}'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 96,
                  child: TextField(
                    controller: _duration,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Duration'),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('min', style: TextStyle(fontSize: 13)),
              ],
            ),
            FilledButton(
              onPressed: _title.text.trim().isEmpty ? null : _save,
              child: Text(_editing == null ? 'Log activity' : 'Save changes'),
            ),
            if (_editing != null)
              TextButton(onPressed: _reset, child: const Text('Cancel edit')),
          ],
        ),
        if (days.isEmpty) Text('Nothing logged yet.', style: meta(size: 13)),
        for (final d in days)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                dayLabel(d),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral800,
                ),
              ),
              const SizedBox(height: 6),
              for (final a
                  in (groups[d]!
                    ..sort((x, y) => y.startTime.compareTo(x.startTime))))
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          child: Text(a.startTime, style: meta()),
                        ),
                        Expanded(
                          child: Text(
                            a.title,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text('${a.durationMinutes} min', style: meta()),
                        TextButton(
                          onPressed: () => _edit(a),
                          child: const Text('Edit'),
                        ),
                        IconButton(
                          tooltip: 'Delete ${a.title}',
                          onPressed: () =>
                              ref.read(databaseProvider).deleteActivity(a.id),
                          icon: const Icon(Icons.close, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
