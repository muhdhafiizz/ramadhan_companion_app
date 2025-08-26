import 'package:flutter/cupertino.dart';
import 'package:quran/quran.dart' as quran;

class QuranDetailProvider extends ChangeNotifier {
  final int surahNumber;
  List<Map<String, String>> _allVerses = [];
  List<Map<String, String>> _filteredVerses = [];
  String _query = "";
  bool _showScrollUp = false;
  bool _showScrollDown = false;

  QuranDetailProvider(this.surahNumber) {
    _loadVerses();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  late ScrollController _scrollController;

  List<Map<String, String>> get verses => _filteredVerses;
  ScrollController get scrollController => _scrollController;
  bool get showScrollUp => _showScrollUp;
  bool get showScrollDown => _showScrollDown;

  void _scrollListener() {
    final offset = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;

    _showScrollUp = offset >= maxScroll - 50;
    _showScrollDown = offset > 20 && offset < maxScroll - 200;

    notifyListeners();
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 500));

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutSine,
    );
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
