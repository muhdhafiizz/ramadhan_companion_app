import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:quran/quran.dart' as quran;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:audioplayers/audioplayers.dart';

enum Reciter { alafasy, husary, shaatree }

class QuranDetailProvider extends ChangeNotifier {
  final int surahNumber;
  final int? initialVerse;

  List<Map<String, String>> _allVerses = [];
  List<Map<String, String>> _filteredVerses = [];
  String _query = "";

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  bool _showScrollUp = false;
  bool _showScrollDown = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  late final StreamSubscription<PlayerState> _playerStateSub;
  late final StreamSubscription<Duration> _durationSub;
  late final StreamSubscription<Duration> _positionSub;

  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Reciter _reciter = Reciter.alafasy;

  int? _playingVerse;

  QuranDetailProvider(this.surahNumber, {this.initialVerse}) {
    _loadVerses();
    _setupScrollListener();
    _setupAudioListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialVerse != null) scrollToVerse(initialVerse!);
    });
  }

  @override
  void dispose() {
    _playerStateSub.cancel();
    _durationSub.cancel();
    _positionSub.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  List<Map<String, String>> get verses => _filteredVerses;
  bool get showScrollUp => _showScrollUp;
  bool get showScrollDown => _showScrollDown;

  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  Reciter get reciter => _reciter;

  int? get playingVerse => _playingVerse;
  bool get isVersePlaying => _playingVerse != null;


  void _setupScrollListener() {
    itemPositionsListener.itemPositions.addListener(() {
      final positions = itemPositionsListener.itemPositions.value;
      if (positions.isEmpty) return;

      final min = positions.reduce((a, b) => a.index < b.index ? a : b).index;
      final max = positions.reduce((a, b) => a.index > b.index ? a : b).index;

      _showScrollUp = min > 0;
      _showScrollDown = max < _filteredVerses.length - 1;

      notifyListeners();
    });
  }

  void scrollToTop() {
    itemScrollController.scrollTo(
      index: 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void scrollToBottom() {
    itemScrollController.scrollTo(
      index: _filteredVerses.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void scrollToVerse(int verseNum) {
    final index = verseNum - 1;
    if (index >= 0 && index < _filteredVerses.length) {
      itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _loadVerses() {
    final verseCount = quran.getVerseCount(surahNumber);
    _allVerses = List.generate(verseCount, (index) {
      final verseNum = index + 1;
      return {
        "number": verseNum.toString(),
        "arabic": quran.getVerse(surahNumber, verseNum, verseEndSymbol: true),
        "translation": quran.getVerseTranslation(surahNumber, verseNum),
      };
    });
    _filteredVerses = List.from(_allVerses);
  }

  void search(String query) {
    _query = query.toLowerCase();
    if (_query.isEmpty) {
      _filteredVerses = List.from(_allVerses);
    } else {
      _filteredVerses = _allVerses
          .where(
            (verse) => verse["translation"]!.toLowerCase().contains(_query),
          )
          .toList();
    }
    notifyListeners();
  }

  void _setupAudioListeners() {
    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((state) async {
      _isPlaying = state == PlayerState.playing;

      if (state == PlayerState.completed) {
        if (_playingVerse != null) {
          _isPlaying = false;
          notifyListeners();
        } else {
          _isPlaying = false;
        }
      }

      notifyListeners();
    });

    _durationSub = _audioPlayer.onDurationChanged.listen((d) {
      _duration = d;
      notifyListeners();
    });

    _positionSub = _audioPlayer.onPositionChanged.listen((p) {
      _position = p;
      notifyListeners();
    });
  }

  Future<void> playAudio({Reciter? reciter}) async {
    if (reciter != null) _reciter = reciter;
    final url = getAudioURLBySurah(surahNumber, reciter: _reciter);
    await _audioPlayer.play(UrlSource(url));
  }

  Future<void> playAudioVerse({required int verse}) async {
    _playingVerse = verse;
    final url = quran.getAudioURLByVerse(surahNumber, verse);
    await _audioPlayer.play(UrlSource(url));
    notifyListeners();
  }

  Future<void> pauseVerseAudio() async {
    await _audioPlayer.pause();
    notifyListeners();
  }

  Future<void> pauseAudio() async => await _audioPlayer.pause();
  Future<void> stopAudio() async => await _audioPlayer.stop();

  String getAudioURLBySurah(
    int surahNumber, {
    Reciter reciter = Reciter.alafasy,
  }) {
    final reciterStr = reciter == Reciter.alafasy
        ? "ar.alafasy"
        : reciter == Reciter.husary
        ? "ar.husary"
        : "ar.shaatree";

    return "https://cdn.islamic.network/quran/audio-surah/128/$reciterStr/$surahNumber.mp3";
  }
}
