import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';

/// Sends a PNG and its caption to the phone's share sheet; faked in tests.
typedef ShareImage = Future<void> Function(Uint8List png, String caption);

Future<void> _systemShare(Uint8List png, String caption) async {
  await SharePlus.instance.share(
    ShareParams(
      text: caption,
      files: [XFile.fromData(png, mimeType: 'image/png', name: 'nurday.png')],
    ),
  );
}

final shareImageProvider = Provider<ShareImage>((ref) => _systemShare);

/// What a share card shows. [reference] is always printed on the image and
/// in the caption, so a shared ayah or hadith never travels without it.
typedef ShareContent = ({
  String kicker,
  String arabic,
  String? text,
  String reference,
});

/// Opens a preview of the card and shares it as an image.
Future<void> showShareCard(BuildContext context, ShareContent c) =>
    showDialog<void>(context: context, builder: (_) => _ShareDialog(c));

class _ShareDialog extends ConsumerStatefulWidget {
  const _ShareDialog(this.c);
  final ShareContent c;

  @override
  ConsumerState<_ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends ConsumerState<_ShareDialog> {
  final _boundary = GlobalKey();
  bool _busy = false;

  Future<void> _share() async {
    setState(() => _busy = true);
    final share = ref.read(shareImageProvider);
    try {
      final box =
          _boundary.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await box.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final c = widget.c;
      await share(
        data!.buffer.asUint8List(),
        [c.arabic, ?c.text, c.reference].join('\n\n'),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RepaintBoundary(key: _boundary, child: ShareCardView(widget.c)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Tr('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  key: const Key('share-confirm'),
                  onPressed: _busy ? null : _share,
                  icon: const Icon(Icons.share, size: 18),
                  label: const Tr('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The image itself: the theme's wash, the Arabic, the translation, the
/// reference and the app name.
class ShareCardView extends StatelessWidget {
  const ShareCardView(this.c, {super.key});
  final ShareContent c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sage200, AppColors.accent200],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Kicker(c.kicker),
          const SizedBox(height: 12),
          Text(
            c.arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: arabicStyle.copyWith(fontSize: 24, color: AppColors.text),
          ),
          if (c.text != null) ...[
            const SizedBox(height: 12),
            Text(
              c.text!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppColors.text,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            c.reference,
            textAlign: TextAlign.center,
            style: meta(size: 12, color: AppColors.neutral800),
          ),
          const SizedBox(height: 10),
          Text(
            'Nurday',
            textAlign: TextAlign.center,
            style: heading(14, color: AppColors.accent700),
          ),
        ],
      ),
    );
  }
}
