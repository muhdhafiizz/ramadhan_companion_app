import 'package:flutter/cupertino.dart';
import 'package:quran/quran.dart' as quran;

class QuranProvider extends ChangeNotifier {
  String _query = "";

  String get query => _query;

  void updateQuery(String value) {
    _query = value;
    notifyListeners();
  }

  List<int> get filteredSurahs {
    return List.generate(quran.totalSurahCount, (i) => i + 1).where((index) {
      final name = quran.getSurahName(index).toLowerCase();
      return name.contains(_query.toLowerCase());
    }).toList();
  }
}
