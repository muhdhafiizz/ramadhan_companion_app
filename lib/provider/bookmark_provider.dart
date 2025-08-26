import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkProvider extends ChangeNotifier {
  List<String> _bookmarks = []; 

  List<String> get bookmarks => _bookmarks;

  BookmarkProvider() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList("bookmarks") ?? [];

    _bookmarks = stored.where(_isValidBookmark).toList();

    if (_bookmarks.length != stored.length) {
      prefs.setStringList("bookmarks", _bookmarks);
    }

    notifyListeners();
  }

  Future<void> toggleBookmark(int surahNumber, int verseNumber) async {
    final key = "$surahNumber:$verseNumber";

    if (_bookmarks.contains(key)) {
      _bookmarks.remove(key);
    } else {
      _bookmarks.add(key);
    }

    _bookmarks = _bookmarks.where(_isValidBookmark).toList();

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList("bookmarks", _bookmarks);
  }

  bool isBookmarked(int surahNumber, int verseNumber) {
    return _bookmarks.contains("$surahNumber:$verseNumber");
  }

  bool _isValidBookmark(String bookmark) {
    final parts = bookmark.split(":");
    if (parts.length != 2) return false;
    final surah = int.tryParse(parts[0]);
    final verse = int.tryParse(parts[1]);
    return surah != null && verse != null && surah > 0 && verse > 0;
  }
}
