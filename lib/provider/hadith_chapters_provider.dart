import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadhan_companion_app/model/hadith_book_model.dart';
import 'package:ramadhan_companion_app/service/hadith_service.dart';

class HadithChaptersProvider extends ChangeNotifier {
  final HadithService _service = HadithService();

  List<HadithChapter> _chapters = [];
  String _searchQuery = "";
  bool _isLoading = false;
  String? _error;

  List<HadithChapter> get chapters {
    if (_searchQuery.isEmpty) return _chapters;
    final query = _searchQuery.toLowerCase();
    return _chapters.where((c) {
      return c.chapterEnglish.toLowerCase().contains(query) ||
          c.chapterArabic.toLowerCase().contains(query);
    }).toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadChapters(
    String bookSlug, {
    bool forceRefresh = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = "chapters_$bookSlug";

      if (!forceRefresh && prefs.containsKey(cacheKey)) {
        final cachedData = prefs.getString(cacheKey);
        if (cachedData != null) {
          final decoded = json.decode(cachedData) as List;
          _chapters = decoded.map((c) => HadithChapter.fromJson(c)).toList();
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      _chapters = await _service.fetchHadithChapters(bookSlug);

      await prefs.setString(
        cacheKey,
        json.encode(_chapters.map((c) => c.toJson()).toList()),
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
