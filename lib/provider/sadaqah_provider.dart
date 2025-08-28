import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:ramadhan_companion_app/model/sadaqah_model.dart';

class SadaqahProvider extends ChangeNotifier {
  SadaqahProvider() {
    _init();
  }

  List<Sadaqah> _allSadaqah = [];
  List<Sadaqah> _filteredSadaqah = [];
  bool _isLoading = false;
  bool _hasShownReminder = false;

  List<Sadaqah> get sadaqahList => _filteredSadaqah;
  bool get isLoading => _isLoading;
  bool get hasShownReminder => _hasShownReminder;

  void _init() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSadaqahList();
    });
  }

  Future<void> loadSadaqahList() async {
    _isLoading = true;
    notifyListeners();

    final String response = await rootBundle.loadString(
      'assets/data/sadaqah.json',
    );
    final List<dynamic> data = json.decode(response);
    _allSadaqah = data.map((e) => Sadaqah.fromJson(e)).toList();
    _filteredSadaqah = _allSadaqah;

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    if (query.isEmpty) {
      _filteredSadaqah = _allSadaqah;
    } else {
      _filteredSadaqah = _allSadaqah.where((s) {
        return s.organization.toLowerCase().contains(query.toLowerCase()) ||
            s.bankName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void markReminderShown() {
    _hasShownReminder = true;
    notifyListeners();
  }

  void dismissReminder() {
    _hasShownReminder = false;
    notifyListeners();
  }
}
