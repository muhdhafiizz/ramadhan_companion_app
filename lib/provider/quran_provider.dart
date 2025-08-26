import 'package:flutter/cupertino.dart';
import 'package:quran/quran.dart' as quran;
import 'package:flutter/material.dart';

class QuranProvider extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();

  String _query = "";
  bool _showScrollUp = false;
  bool _showScrollDown = false;

  QuranProvider() {
    scrollController.addListener(_scrollListener);
  }

  String get query => _query;
  bool get showScrollUp => _showScrollUp;
  bool get showScrollDown => _showScrollDown;

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

  void _scrollListener() {
    final offset = scrollController.offset;
    final maxScroll = scrollController.position.maxScrollExtent;

    _showScrollUp = offset > 200;
    _showScrollDown = offset < maxScroll - 200;

    notifyListeners();
  }

  Future<void> scrollToTop() async {
    await scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 50));

    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

