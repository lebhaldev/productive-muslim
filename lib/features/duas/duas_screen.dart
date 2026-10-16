import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/db/database.dart';
import '../../widgets/common.dart';
import '../../widgets/locked_view.dart';
import '../more/more_screen.dart';

/// The user's own duas, on this phone only, behind the journal lock (FR-20).
/// The app never adds text to this list.
class DuasScreen extends ConsumerStatefulWidget {
  const DuasScreen({super.key});

  @override
  ConsumerState<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends ConsumerState<DuasScreen> {
  final _text = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_text.text.trim().isEmpty) return;
    await ref
        .read(databaseProvider)
        .addDua(_text.text, _note.text, ref.read(clockProvider).now());
    _text.clear();
    _note.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(journalLockedProvider)) {
      return const Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: MoreTitle('Duas'),
          ),
          Expanded(
            child: LockedView(
              title: 'Your duas are locked',
              reason: 'Unlock your Nurday duas',
              unlockKey: Key('unlock-duas'),
            ),
          ),
        ],
      );
    }
    final all = ref.watch(duasProvider).value ?? const <Dua>[];
    final asking = all.where((d) => d.answeredAt == null).toList();
    final answered = all.where((d) => d.answeredAt != null).toList()
      ..sort((a, b) => b.answeredAt!.compareTo(a.answeredAt!));

    return ScreenBody(
      gap: 12,
      children: [
        const MoreTitle('Duas'),
        TextField(
          key: const Key('dua-text'),
          controller: _text,
          minLines: 1,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Write a dua'),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('dua-note'),
                controller: _note,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Note (optional)'),
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              key: const Key('dua-add'),
              onPressed: _add,
              child: const Text('Add'),
            ),
          ],
        ),
        if (all.isEmpty)
          Text(
            'Write the duas you are making. Only you see them.',
            style: meta(size: 13),
          ),
        if (asking.isNotEmpty) ...[
          Text('Asking · ${asking.length}', style: heading(17)),
          for (final d in asking) _DuaRow(dua: d),
        ],
        if (answered.isNotEmpty) ...[
          Text('Answered · ${answered.length}', style: heading(17)),
          for (final d in answered) _DuaRow(dua: d),
        ],
      ],
    );
  }
}

enum _DuaAction { edit, unanswer, delete }

class _DuaRow extends ConsumerWidget {
  const _DuaRow({required this.dua});
  final Dua dua;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    final day = DateFormat('d MMM');
    final isAnswered = dua.answeredAt != null;
    return Container(
      key: Key('dua-${dua.id}'),
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dua.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
                if (dua.note != null) Text(dua.note!, style: meta(size: 13)),
                const SizedBox(height: 2),
                Text(
                  isAnswered
                      ? 'Answered ${day.format(dua.answeredAt!)}'
                      : 'Added ${day.format(dua.createdAt)}',
                  style: meta(color: isAnswered ? AppColors.sage900 : null),
                ),
              ],
            ),
          ),
          if (!isAnswered)
            IconButton(
              key: Key('dua-answer-${dua.id}'),
              tooltip: 'Mark answered',
              onPressed: () =>
                  db.setDuaAnswered(dua.id, ref.read(clockProvider).now()),
              icon: Icon(Icons.check_circle_outline, color: AppColors.sage600),
            ),
          PopupMenuButton<_DuaAction>(
            key: Key('dua-menu-${dua.id}'),
            tooltip: 'More',
            onSelected: (a) => switch (a) {
              _DuaAction.edit => _edit(context, ref),
              _DuaAction.unanswer => db.setDuaAnswered(dua.id, null),
              _DuaAction.delete => _confirmDelete(context, ref),
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: _DuaAction.edit, child: Text('Edit')),
              if (isAnswered)
                const PopupMenuItem(
                  value: _DuaAction.unanswer,
                  child: Text('Move back to Asking'),
                ),
              const PopupMenuItem(
                value: _DuaAction.delete,
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final text = TextEditingController(text: dua.body);
    final note = TextEditingController(text: dua.note ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Edit dua'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('dua-edit-text'),
              controller: text,
              minLines: 1,
              maxLines: 4,
            ),
            TextField(
              key: const Key('dua-edit-note'),
              controller: note,
              decoration: const InputDecoration(hintText: 'Note (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok == true && text.text.trim().isNotEmpty) {
      await ref.read(databaseProvider).editDua(dua.id, text.text, note.text);
    }
    text.dispose();
    note.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete this dua?'),
        content: const Text('It is removed from this phone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(databaseProvider).deleteDua(dua.id);
  }
}
