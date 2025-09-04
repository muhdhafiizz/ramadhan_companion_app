import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadhan_companion_app/model/hadith_book_model.dart';
import 'package:ramadhan_companion_app/service/hadith_service.dart';

class HadithBooksProvider extends ChangeNotifier {
  final HadithService _service = HadithService();

  List<HadithBook> _books = [];
  bool _isLoading = false;
  String? _error;

  List<HadithBook> get books => _books;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const _cacheKey = "cached_books";

  Future<void> loadBooks({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      if (!forceRefresh) {
        final cachedData = prefs.getString(_cacheKey);
        if (cachedData != null) {
          final List decoded = jsonDecode(cachedData);
          _books = decoded.map((e) => HadithBook.fromJson(e)).toList();

          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      _books = await _service.fetchHadithBooks();

      final encoded = jsonEncode(_books.map((b) => b.toJson()).toList());
      await prefs.setString(_cacheKey, encoded);

    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
