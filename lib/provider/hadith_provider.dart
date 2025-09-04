import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadhan_companion_app/model/hadith_book_model.dart';
import 'package:ramadhan_companion_app/service/hadith_service.dart';

class HadithProvider extends ChangeNotifier {
  final HadithService _service = HadithService();

  List<HadithModel> _hadiths = [];
  int _currentPage = 1;
  int _selectedIndex = 0;
  bool _isLoading = false;
  String? _error;
  String? _chapterId;

  List<HadithModel> get hadiths => _hadiths;
  HadithModel? get currentHadith =>
      _hadiths.isNotEmpty ? _hadiths[_selectedIndex] : null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHadiths(
    String bookSlug, {
    int page = 1,
    String? chapterId,
    bool forceRefresh = false,
  }) async {
    _isLoading = true;
    _error = null;

    if (page == 1) {
      _hadiths = [];
      _selectedIndex = 0;
      _chapterId = chapterId;
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = "hadiths_${bookSlug}_${chapterId ?? 'all'}_page_$page";

      // ✅ Use cached version if available (unless forced refresh)
      if (!forceRefresh && prefs.containsKey(cacheKey)) {
        final cachedData = prefs.getString(cacheKey);
        if (cachedData != null) {
          final decoded = json.decode(cachedData) as List;
          final cachedHadiths = decoded
              .map((h) => HadithModel.fromJson(h))
              .toList();

          if (cachedHadiths.isNotEmpty) {
            if (page == 1) {
              _hadiths = cachedHadiths;
            } else {
              _hadiths.addAll(cachedHadiths);
            }
            _currentPage = page; // ✅ Only update if not empty
          }
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      final newHadiths = await _service.fetchHadiths(
        bookSlug: bookSlug,
        page: page,
        chapterId: _chapterId,
      );

      if (newHadiths.isEmpty) {
        // ✅ Stop here, don’t update page
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (page == 1) {
        _hadiths = newHadiths;
      } else {
        _hadiths.addAll(newHadiths);
      }
      _currentPage = page; 

      await prefs.setString(
        cacheKey,
        json.encode(newHadiths.map((h) => h.toJson()).toList()),
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectHadith(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void nextHadith() {
    if (_selectedIndex < _hadiths.length - 1) {
      _selectedIndex++;
      notifyListeners();
    }
  }

  void previousHadith() {
    if (_selectedIndex > 0) {
      _selectedIndex--;
      notifyListeners();
    }
  }

  String get hadithPositionText {
    if (_hadiths.isEmpty) return "0/0";
    return "${_selectedIndex + 1}/${_hadiths.length}";
  }

  Future<void> loadMore(String bookSlug) async {
    await loadHadiths(bookSlug, page: _currentPage + 1, chapterId: _chapterId);
  }
}
