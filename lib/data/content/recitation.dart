import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import 'quran_client.dart';

/// A verse-by-verse audio edition on AlQuran Cloud, e.g. `ar.alafasy`.
typedef Reciter = ({String id, String name, String englishName});

/// A surah of the Qur'an as AlQuran Cloud lists it.
typedef SurahInfo = ({int number, String name, String englishName, int ayahs});

/// One recited ayah: its number in the surah and the recording's URL.
typedef AyahAudio = ({int numberInSurah, String url});

/// Mishary Alafasy, used until the user picks a reciter.
const defaultReciter = 'ar.alafasy';

/// Recitation audio and its metadata from AlQuran Cloud (the same source as
/// the ayah text). The recordings are the reciters' own; the app only plays
/// them.
class RecitationClient {
  RecitationClient(this._http);
  final http.Client _http;

  static const _api = 'https://api.alquran.cloud/v1';

  Future<dynamic> _get(String path) async {
    final http.Response res;
    try {
      res = await _http
          .get(Uri.parse('$_api$path'))
          .timeout(const Duration(seconds: 12));
    } catch (_) {
      throw ContentSourceException(QuranClient.alQuranCloud, 'no connection');
    }
    if (res.statusCode != 200) {
      throw ContentSourceException(
        QuranClient.alQuranCloud,
        'HTTP ${res.statusCode}',
      );
    }
    try {
      return (jsonDecode(utf8.decode(res.bodyBytes)) as Map)['data'];
    } catch (_) {
      throw ContentSourceException(
        QuranClient.alQuranCloud,
        'unexpected response',
      );
    }
  }

  /// Arabic verse-by-verse audio editions.
  Future<List<Reciter>> reciters() async {
    final data = await _get('/edition?format=audio&type=versebyverse') as List;
    return [
      for (final e in data.cast<Map>())
        if (e['language'] == 'ar' && e['identifier'] is String)
          (
            id: e['identifier'] as String,
            name: (e['name'] ?? e['englishName']) as String,
            englishName: (e['englishName'] ?? e['identifier']) as String,
          ),
    ]..sort((a, b) => a.englishName.compareTo(b.englishName));
  }

  Future<List<SurahInfo>> surahs() async {
    final data = await _get('/surah') as List;
    return [
      for (final s in data.cast<Map>())
        (
          number: s['number'] as int,
          name: s['name'] as String,
          englishName: s['englishName'] as String,
          ayahs: s['numberOfAyahs'] as int,
        ),
    ];
  }

  /// The recording of one ayah (`94:5`) by [reciter].
  Future<String> ayahAudio(String ref, String reciter) async {
    final data = await _get('/ayah/$ref/$reciter') as Map;
    final url = data['audio'];
    if (url is! String || !url.startsWith('https://')) {
      throw ContentSourceException(
        QuranClient.alQuranCloud,
        'no recording for this ayah',
      );
    }
    return url;
  }

  /// Every ayah of surah [number] by [reciter], in order.
  Future<List<AyahAudio>> surahAudio(int number, String reciter) async {
    final data = await _get('/surah/$number/$reciter') as Map;
    return [
      for (final a in (data['ayahs'] as List).cast<Map>())
        if (a['audio'] case final String url when url.startsWith('https://'))
          (numberInSurah: a['numberInSurah'] as int, url: url),
    ];
  }
}

/// What is playing now, for the controls.
typedef PlaybackState = ({
  String? queueId,
  int index,
  int length,
  bool playing,
  bool loading,
});

const PlaybackState idlePlayback = (
  queueId: null,
  index: 0,
  length: 0,
  playing: false,
  loading: false,
);

/// Plays a queue of recordings; faked in tests.
abstract interface class RecitationPlayer {
  Stream<PlaybackState> get states;
  PlaybackState get state;

  /// Plays [urls] from [start]. [queueId] names what is playing
  /// (e.g. `ayah:94:5` or `surah:36`) so the screens can show it.
  Future<void> play(String queueId, List<String> urls, {int start = 0});
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> next();
  Future<void> previous();
}

class JustAudioPlayer implements RecitationPlayer {
  final _player = AudioPlayer();
  final _states = StreamController<PlaybackState>.broadcast();
  PlaybackState _state = idlePlayback;
  bool _listening = false;

  @override
  Stream<PlaybackState> get states => _states.stream;
  @override
  PlaybackState get state => _state;

  void _emit(PlaybackState s) {
    _state = s;
    _states.add(s);
  }

  void _listen() {
    if (_listening) return;
    _listening = true;
    _player.playerStateStream.listen((p) {
      final done = p.processingState == ProcessingState.completed;
      _emit((
        queueId: done ? null : _state.queueId,
        index: _state.index,
        length: _state.length,
        playing: p.playing && !done,
        loading:
            p.processingState == ProcessingState.loading ||
            p.processingState == ProcessingState.buffering,
      ));
    });
    _player.currentIndexStream.listen((i) {
      if (i == null) return;
      _emit((
        queueId: _state.queueId,
        index: i,
        length: _state.length,
        playing: _state.playing,
        loading: _state.loading,
      ));
    });
  }

  @override
  Future<void> play(String queueId, List<String> urls, {int start = 0}) async {
    _listen();
    _emit((
      queueId: queueId,
      index: start,
      length: urls.length,
      playing: true,
      loading: true,
    ));
    await _player.setAudioSources([
      for (final u in urls) AudioSource.uri(Uri.parse(u)),
    ], initialIndex: start);
    unawaited(_player.play());
  }

  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> resume() => _player.play();
  @override
  Future<void> stop() async {
    await _player.stop();
    _emit(idlePlayback);
  }

  @override
  Future<void> next() => _player.seekToNext();
  @override
  Future<void> previous() => _player.seekToPrevious();
}
