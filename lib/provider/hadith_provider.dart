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
  bool _hasMore = true;
  String? _error;
  String? _chapterId;

  List<HadithModel> get hadiths => _hadiths;
  HadithModel? get currentHadith =>
      _hadiths.isNotEmpty ? _hadiths[_selectedIndex] : null;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
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
      _hasMore = true;
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = "hadiths_${bookSlug}_${chapterId ?? 'all'}_page_$page";

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
            _currentPage = page;
          } else {
            _hasMore = false;
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
        _hasMore = false;
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
      _hasMore = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectHadith(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> nextHadith(String bookSlug) async {
    try {
      if (_selectedIndex < _hadiths.length - 1) {
        _selectedIndex++;
      } else if (_hasMore && !_isLoading) {
        final previousCount = _hadiths.length;
        await loadMore(bookSlug);

        if (_hadiths.length > previousCount) {
          _selectedIndex++;
        } else {
          _hasMore = false;
        }
      } else {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
      _hasMore = false;
    } finally {
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
    if (!_hasMore || _isLoading) return;
    await loadHadiths(bookSlug, page: _currentPage + 1, chapterId: _chapterId);
  }
}
