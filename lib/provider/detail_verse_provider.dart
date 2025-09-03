import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran/quran.dart' as quran;

class DailyVerseProvider extends ChangeNotifier {
  List<Map<String, int>> _verseRefs = [];

  List<Map<String, int>> get verseRefs => _verseRefs;

  DailyVerseProvider() {
    _loadVerses();
  }

  Future<void> _loadVerses() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final savedDate = prefs.getString("lastGeneratedDate");
    final savedRefs = prefs.getStringList("dailyVerses");

    if (savedDate == today && savedRefs != null) {
      _verseRefs = savedRefs.map((s) {
        final parts = s.split(":");
        return {"surah": int.parse(parts[0]), "ayah": int.parse(parts[1])};
      }).toList();
    } else {
      final random = Random();
      _verseRefs = List.generate(5, (_) {
        final surah = random.nextInt(114) + 1;
        final ayah = random.nextInt(quran.getVerseCount(surah)) + 1;
        return {"surah": surah, "ayah": ayah};
      });

      await prefs.setString("lastGeneratedDate", today);
      await prefs.setStringList(
        "dailyVerses",
        _verseRefs.map((ref) => "${ref["surah"]}:${ref["ayah"]}").toList(),
      );
    }

    notifyListeners();
  }
}
