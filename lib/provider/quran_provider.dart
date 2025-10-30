import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';

class QuranProvider extends ChangeNotifier {
  final ScrollController surahScrollController = ScrollController();
  final ScrollController pageScrollController = ScrollController();

  String _query = "";
  List<Map<String, String>> _allVerses = [];
  List<Map<String, String>> _filteredVerses = [];
  final int surahNumber;
  bool _showScrollUp = false;
  bool _showScrollDown = false;
  bool showByPage = false;
  double _arabicFontSize = 23;
  double _translationFontSize = 16;
  int _currentPageNumber = 1;
  quran.Translation _selectedTranslation = quran.Translation.enSaheeh;

  QuranProvider(this.surahNumber) {
    surahScrollController.addListener(
      () => _scrollListener(surahScrollController),
    );
    pageScrollController.addListener(
      () => _scrollListener(pageScrollController),
    );
  }

  String get query => _query;
  bool get showScrollUp => _showScrollUp;
  bool get showScrollDown => _showScrollDown;
  double get arabicFontSize => _arabicFontSize;
  double get translationFontSize => _translationFontSize;
  int get currentPageNumber => _currentPageNumber;
  List<Map<String, String>> get verses => _filteredVerses;
  quran.Translation get selectedTranslation => _selectedTranslation;

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

  void updateQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setViewMode(bool byPage) {
    showByPage = byPage;
    notifyListeners();
  }

  List<int> get filteredSurahs {
    return List.generate(quran.totalSurahCount, (i) => i + 1).where((index) {
      final name = quran.getSurahName(index).toLowerCase();
      return name.contains(_query.toLowerCase());
    }).toList();
  }

  void setCurrentPage(int page) {
    _currentPageNumber = page;
    notifyListeners();
  }

  List<int> get filteredPages {
    final pages = getQuranPages().keys.toList()..sort();
    if (_query.isEmpty) return pages;

    final queryNum = int.tryParse(_query);
    if (queryNum != null) {
      return pages.where((p) => p == queryNum).toList();
    }

    return pages.where((page) {
      final verses = getQuranPages()[page]!;
      final first = verses.first;
      final juz = quran.getJuzNumber(first['surah']!, first['verse']!);
      return "juz $juz".contains(_query.toLowerCase());
    }).toList();
  }

  Future<void> setTranslationLanguage(quran.Translation translation) async {
    _selectedTranslation = translation;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_translation', translation.name);
    _reloadTranslations();
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

  final Map<int, List<Map<String, int>>> _cachedPages = {};

  Map<int, List<Map<String, int>>> getQuranPages() {
    if (_cachedPages.isNotEmpty) return _cachedPages;

    final Map<int, List<Map<String, int>>> pages = {};
    for (int surah = 1; surah <= 114; surah++) {
      int verses = quran.getVerseCount(surah);
      for (int verse = 1; verse <= verses; verse++) {
        int page = quran.getPageNumber(surah, verse);
        pages.putIfAbsent(page, () => []);
        pages[page]!.add({'surah': surah, 'verse': verse});
      }
    }
    _cachedPages.addAll(pages);
    return _cachedPages;
  }

  // ------------------ SCROLL ------------------
  void _scrollListener(ScrollController controller) {
    if (!controller.hasClients) return;

    final offset = controller.offset;
    final maxScroll = controller.position.maxScrollExtent;
    _showScrollUp = offset > 200;
    _showScrollDown = offset < maxScroll - 200;
    notifyListeners();
  }

  Future<void> scrollToTop() async {
    final controller = showByPage
        ? pageScrollController
        : surahScrollController;
    await controller.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 50));
    final controller = showByPage
        ? pageScrollController
        : surahScrollController;

    await controller.animateTo(
      controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    surahScrollController.dispose();
    super.dispose();
  }
}
