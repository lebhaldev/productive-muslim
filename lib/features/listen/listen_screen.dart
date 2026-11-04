import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/content/quran_client.dart';
import '../../data/content/recitation.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';
import '../more/more_screen.dart';
import '../settings/settings_widgets.dart';

/// Plays recitation of [queueId] built from [load]; shows errors as a
/// snackbar naming the source. Shared by the Listen screen and the ayah card.
Future<void> playRecitation(
  BuildContext context,
  WidgetRef ref,
  String queueId,
  Future<List<String>> Function(RecitationClient c) load, {
  int start = 0,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final urls = await load(ref.read(recitationClientProvider));
    if (urls.isEmpty) return;
    await ref.read(recitationPlayerProvider).play(queueId, urls, start: start);
  } catch (e) {
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          e is ContentSourceException
              ? tr('{0} could not be reached', [e.source])
              : tr('The recitation could not be played.'),
        ),
      ),
    );
  }
}

/// Reciter dropdown, from AlQuran Cloud's audio editions; saved as a setting.
class ReciterPicker extends ConsumerWidget {
  const ReciterPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reciters = ref.watch(recitersProvider);
    final current = settingsOf(ref).reciter;
    return reciters.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const Note(
        'The list of reciters needs a connection once. Mishary Alafasy is used until then.',
      ),
      data: (list) {
        final options = {for (final r in list) r.id: r.englishName};
        options.putIfAbsent(current, () => current);
        return SettingPicker<String>(
          key: const Key('reciter'),
          label: 'Reciter',
          value: current,
          options: options,
          onChanged: (id) => ref.putSetting('reciter', id),
        );
      },
    );
  }
}

/// More → Listen to the Quran: pick a surah and a reciter and listen,
/// ayah by ayah. Audio streams from AlQuran Cloud; the app shows no Qur'an
/// text here and is not a mushaf.
class ListenScreen extends ConsumerStatefulWidget {
  const ListenScreen({super.key});

  @override
  ConsumerState<ListenScreen> createState() => _ListenScreenState();
}

class _ListenScreenState extends ConsumerState<ListenScreen> {
  int _surah = 1;

  @override
  Widget build(BuildContext context) {
    final surahs = ref.watch(surahsProvider);
    final playback = ref.watch(playbackProvider).value ?? idlePlayback;
    final reciter = settingsOf(ref).reciter;
    final queue = 'surah:$_surah';
    final thisPlaying = playback.queueId == queue;
    final player = ref.read(recitationPlayerProvider);
    return ScreenBody(
      children: [
        const MoreTitle('Listen to the Quran'),
        NCard(
          gap: 12,
          children: [
            const ReciterPicker(),
            surahs.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Note(
                e is ContentSourceException
                    ? tr('{0} could not be reached', [e.source])
                    : tr('The list of surahs could not load.'),
                warn: true,
              ),
              data: (list) => SettingPicker<int>(
                key: const Key('surah'),
                label: 'Surah',
                value: _surah,
                options: {
                  for (final s in list)
                    s.number: '${s.number}. ${s.englishName} · ${s.name}',
                },
                onChanged: (n) => setState(() => _surah = n),
              ),
            ),
          ],
        ),
        NCard(
          gap: 10,
          children: [
            if (thisPlaying)
              Tr(
                'Ayah {0} of {1}',
                args: [playback.index + 1, playback.length],
                key: const Key('listen-position'),
                textAlign: TextAlign.center,
                style: heading(22),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundIconButton(
                  icon: Icons.skip_previous,
                  label: 'Previous ayah',
                  onPressed: thisPlaying ? player.previous : null,
                ),
                const SizedBox(width: 16),
                IconButton.filled(
                  key: const Key('listen-play'),
                  iconSize: 40,
                  tooltip: thisPlaying && playback.playing
                      ? tr('Pause')
                      : tr('Play'),
                  onPressed: () {
                    if (thisPlaying && playback.playing) {
                      player.pause();
                    } else if (thisPlaying) {
                      player.resume();
                    } else {
                      playRecitation(
                        context,
                        ref,
                        queue,
                        (c) async => [
                          for (final a in await c.surahAudio(_surah, reciter))
                            a.url,
                        ],
                      );
                    }
                  },
                  icon: Icon(
                    thisPlaying && playback.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                ),
                const SizedBox(width: 16),
                RoundIconButton(
                  icon: Icons.skip_next,
                  label: 'Next ayah',
                  onPressed: thisPlaying ? player.next : null,
                ),
              ],
            ),
            if (thisPlaying && playback.loading)
              const LinearProgressIndicator(),
          ],
        ),
        const Note(
          'Recitation streams from AlQuran Cloud (cdn.islamic.network) while you listen. Only the surah number and the reciter are sent. Playback stops when Nurday is closed.',
        ),
      ],
    );
  }
}

/// A slim bar above the tabs while something is playing: pause or stop.
class NowPlayingBar extends ConsumerWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(playbackProvider).value ?? idlePlayback;
    if (p.queueId == null) return const SizedBox.shrink();
    final player = ref.read(recitationPlayerProvider);
    final label = p.queueId!.startsWith('surah:')
        ? tr('Surah {0} · ayah {1} of {2}', [
            p.queueId!.substring(6),
            p.index + 1,
            p.length,
          ])
        : tr('Ayah {0}', [p.queueId!.substring(5)]);
    return Material(
      key: const Key('now-playing'),
      color: AppColors.sage200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Row(
          children: [
            Icon(Icons.graphic_eq, size: 18, color: AppColors.sage900),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: AppColors.sage900),
              ),
            ),
            IconButton(
              tooltip: p.playing ? tr('Pause') : tr('Play'),
              icon: Icon(p.playing ? Icons.pause : Icons.play_arrow),
              color: AppColors.sage900,
              onPressed: p.playing ? player.pause : player.resume,
            ),
            IconButton(
              key: const Key('now-playing-stop'),
              tooltip: tr('Stop'),
              icon: const Icon(Icons.stop),
              color: AppColors.sage900,
              onPressed: player.stop,
            ),
          ],
        ),
      ),
    );
  }
}
