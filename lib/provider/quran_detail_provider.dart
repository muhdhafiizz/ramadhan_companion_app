import 'package:flutter/cupertino.dart';
import 'package:quran/quran.dart' as quran;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class QuranDetailProvider extends ChangeNotifier {
  final int surahNumber;
  final int? initialVerse;

  List<Map<String, String>> _allVerses = [];
  List<Map<String, String>> _filteredVerses = [];
  String _query = "";
  bool _showScrollUp = false;
  bool _showScrollDown = false;

  // instead of ScrollController + GlobalKeys
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  QuranDetailProvider(this.surahNumber, {this.initialVerse}) {
    _loadVerses();

    // listen for scroll changes
    itemPositionsListener.itemPositions.addListener(() {
      final positions = itemPositionsListener.itemPositions.value;
      if (positions.isEmpty) return;

      final min = positions.reduce((a, b) => a.index < b.index ? a : b).index;
      final max = positions.reduce((a, b) => a.index > b.index ? a : b).index;

      _showScrollUp = min > 0;
      _showScrollDown = max < _filteredVerses.length - 1;

      notifyListeners();
    });

    // scroll to initial verse after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialVerse != null) {
        scrollToVerse(initialVerse!);
      }
    });
  }

  List<Map<String, String>> get verses => _filteredVerses;
  bool get showScrollUp => _showScrollUp;
  bool get showScrollDown => _showScrollDown;

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
}
