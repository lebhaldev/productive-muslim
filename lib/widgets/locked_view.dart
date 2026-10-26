import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/theme.dart';

/// Shown instead of the journal or duas while the journal lock is on.
class LockedView extends ConsumerStatefulWidget {
  const LockedView({
    super.key,
    required this.title,
    required this.reason,
    this.unlockKey,
    this.subtitle = 'Use your fingerprint, face or screen lock to open it.',
  });
  final String title;
  final String subtitle;

  /// What Android's unlock prompt says.
  final String reason;
  final Key? unlockKey;

  @override
  ConsumerState<LockedView> createState() => _LockedViewState();
}

class _LockedViewState extends ConsumerState<LockedView> {
  bool _failed = false;

  Future<void> _unlock() async {
    final ok = await ref.read(appLockProvider).unlock(widget.reason);
    if (!mounted) return;
    if (ok) {
      ref.read(journalUnlockedProvider.notifier).set(true);
    } else {
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.sage200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 34,
                color: AppColors.sage900,
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.title, textAlign: TextAlign.center, style: heading(22)),
            const SizedBox(height: 6),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: meta(size: 13),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: widget.unlockKey,
              onPressed: _unlock,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Unlock'),
            ),
            if (_failed) ...[
              const SizedBox(height: 8),
              Text(
                'Not unlocked. Try again.',
                style: meta(color: AppColors.accent700),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
