import 'package:flutter/cupertino.dart';
import 'package:quran/quran.dart' as quran;

class QuranDetailProvider extends ChangeNotifier {
  final int surahNumber;
  QuranDetailProvider(this.surahNumber) {
    _loadVerses();
  }

  List<Map<String, String>> _allVerses = [];
  List<Map<String, String>> _filteredVerses = [];
  String _query = "";

  List<Map<String, String>> get verses => _filteredVerses;

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
      _filteredVerses = _allVerses.where((verse) {
        return verse["translation"]!.toLowerCase().contains(_query);
      }).toList();
    }
    notifyListeners();
  }
}
