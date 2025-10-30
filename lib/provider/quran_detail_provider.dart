import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadhan_companion_app/service/quran_daily_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Reciter { alafasy, husary, shaatree }

class QuranDetailProvider extends ChangeNotifier {
  int _currentSurah;
  final int? initialVerse;

  int get surahNumber => _currentSurah;

  List<Map<String, String>> _allVerses = [];
  List<Map<String, String>> _filteredVerses = [];
  String _query = "";
  double _arabicFontSize = 23;
  double _translationFontSize = 16;
  quran.Translation _selectedTranslation = quran.Translation.enSaheeh;

  quran.Translation get selectedTranslation => _selectedTranslation;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  bool _showScrollUp = false;
  bool _showScrollDown = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  late final StreamSubscription<PlayerState> _playerStateSub;
  late final StreamSubscription<Duration> _durationSub;
  late final StreamSubscription<Duration> _positionSub;

  final Map<int, String> _tafsirCache = {};

  final Set<int> _expandedVerses = {};

  bool isExpanded(int verseNum) => _expandedVerses.contains(verseNum);

  String? getTafsir(int verseNum) => _tafsirCache[verseNum];

  bool _isPlaying = false;
  bool _showAppBar = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Reciter _reciter = Reciter.alafasy;

  int? _playingVerse;

  QuranDetailProvider(int initialSurah, {this.initialVerse})
    : _currentSurah = initialSurah {
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
  double get arabicFontSize => _arabicFontSize;
  double get translationFontSize => _translationFontSize;

  bool get isPlaying => _isPlaying;
  bool get showAppBar => _showAppBar;
  Duration get duration => _duration;
  Duration get position => _position;
  Reciter get reciter => _reciter;

  int? get playingVerse => _playingVerse;
  bool get isVersePlaying => _playingVerse != null;
  double _lastOffset = 0;

  final List<Map<String, dynamic>> availableTranslations = [
    {
      "name": "English (Sahih International)",
      "value": quran.Translation.enSaheeh,
    },
    {"name": "English", "value": quran.Translation.enClearQuran},
    {"name": "Bahasa Malaysia", "value": quran.Translation.indonesian},
    {"name": "Mandarin", "value": quran.Translation.chinese},
    {"name": "Français (Hamidullah)", "value": quran.Translation.frHamidullah},
  ];

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

  Future<void> loadSurah(int newSurahNumber) async {
    // Clear tafsir cache and reset verse expansion
    _tafsirCache.clear();
    _expandedVerses.clear();

    // Update surah number
    _currentSurah = newSurahNumber;

    // Reload verses
    _loadVerses();

    // Reset scroll position
    scrollToTop();

    notifyListeners();
  }

  Future<void> setTranslationLanguage(quran.Translation translation) async {
    _selectedTranslation = translation;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_translation', translation.name);
    _reloadTranslations();
  }

  Future<void> loadSavedTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('selected_translation');

    if (savedName != null) {
      try {
        _selectedTranslation = quran.Translation.values.firstWhere(
          (t) => t.name == savedName,
          orElse: () => quran.Translation.enSaheeh,
        );
      } catch (e) {
        _selectedTranslation = quran.Translation.enSaheeh;
      }
      _reloadTranslations();
    }
  }

  void _reloadTranslations() {
    final verseCount = quran.getVerseCount(surahNumber);
    _allVerses = List.generate(verseCount, (index) {
      final verseNum = index + 1;
      return {
        "number": verseNum.toString(),
        "arabic": quran.getVerse(surahNumber, verseNum, verseEndSymbol: true),
        "translation": quran.getVerseTranslation(
          surahNumber,
          verseNum,
          translation: _selectedTranslation,
        ),
      };
    });
    _filteredVerses = List.from(_allVerses);
    notifyListeners();
  }

  void setArabicFontSize(double size) {
    _arabicFontSize = size;
    notifyListeners();
  }

  void setTranslationFontSize(double size) {
    _translationFontSize = size;
    notifyListeners();
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

  void handleScroll(double offset) {
    if (offset > _lastOffset && _showAppBar) {
      _showAppBar = false;
      notifyListeners();
    } else if (offset < _lastOffset && !_showAppBar) {
      _showAppBar = true;
      notifyListeners();
    }
    _lastOffset = offset;
  }

  void _loadVerses() {
    final verseCount = quran.getVerseCount(_currentSurah);
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

  Future<void> toggleTafsir(int verseNum) async {
    if (_expandedVerses.contains(verseNum)) {
      _expandedVerses.remove(verseNum);
      notifyListeners();
      return;
    }

    _expandedVerses.add(verseNum);

    if (!_tafsirCache.containsKey(verseNum)) {
      try {
        final tafsir = await QuranDailyService().fetchTafsirAyah(
          "en-al-jalalayn",
          surahNumber,
          verseNum,
        );
        _tafsirCache[verseNum] = tafsir ?? "No tafsir available";
      } catch (e) {
        _tafsirCache[verseNum] = "Error loading tafsir";
      }
    }

    notifyListeners();
  }

  void search(String query) {
    _query = query.toLowerCase();
    if (_query.isEmpty) {
      _filteredVerses = List.from(_allVerses);
    } else {
      _filteredVerses = _allVerses.where((verse) {
        final translation = verse["translation"]?.toLowerCase() ?? "";
        final verseNumber = verse["number"].toString();

        return translation.contains(_query) || verseNumber.contains(_query);
      }).toList();
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
