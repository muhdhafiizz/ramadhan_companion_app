import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ramadhan_companion_app/model/hijri_date_model.dart';
import 'package:ramadhan_companion_app/model/prayer_times_model.dart';
import 'package:ramadhan_companion_app/model/quran_daily_model.dart';
import 'package:ramadhan_companion_app/model/random_hadith_model.dart';
import 'package:ramadhan_companion_app/service/hijri_date_service.dart';
import 'package:ramadhan_companion_app/service/prayer_times_service.dart';
import 'package:ramadhan_companion_app/service/quran_daily_service.dart';
import 'package:ramadhan_companion_app/service/random_hadith_service.dart';

class PrayerTimesProvider extends ChangeNotifier {
  bool _isPrayerTimesLoading = false;
  final bool _isQuranVerseLoading = false;
  final bool _isHijriDateLoading = false;
  bool _shouldAskLocation = false;
  String? _error;
  String? _city;
  String? _country;
  String _countdownText = "";
  String _nextPrayerText = "";
  Timer? _countdownTimer;
  String? _hijriDate;
  String? _hijriDay;
  String? _hijriMonth;
  String? _hijriYear;
  HijriDateModel? _hijriDateModel;
  PrayerTimesModel? _times;
  QuranDailyModel? _quranDaily;
  RandomHadithModel? _hadithDaily;

  final quranService = QuranDailyService();
  final hadithService = RandomHadithService();

  bool get isPrayerTimesLoading => _isPrayerTimesLoading;
  bool get isQuranVerseLoading => _isQuranVerseLoading;
  bool get isHijriDateLoading => _isHijriDateLoading;
  bool get shouldAskLocation => _shouldAskLocation;
  String? get error => _error;
  String? get city => _city;
  String? get country => _country;
  String get countdownText => _countdownText;
  String get nextPrayerText => _nextPrayerText;
  String? get hijriDate => _hijriDate;
  String? get hijriDay => _hijriDay;
  String? get hijriMonth => _hijriMonth;
  String? get hijriYear => _hijriYear;
  PrayerTimesModel? get times => _times;
  HijriDateModel? get hijriDateModel => _hijriDateModel;
  QuranDailyModel? get quranDaily => _quranDaily;
  RandomHadithModel? get hadithDaily => _hadithDaily;

  PrayerTimesProvider() {
    _init();
  }

  void _init() {
    if (times == null) {
      _shouldAskLocation = true;
      notifyListeners();
    }
  }

  Future<void> fetchPrayerTimes(String city, String country) async {
    _isPrayerTimesLoading = true;
    _error = null;
    _city = city;
    _country = country;
    notifyListeners();

    try {
      _times = await PrayerTimesService().getPrayerTimes(city, country);
      startCountdown();
      _hijriDateModel = await HijriDateService().getTodayHijriDate();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isPrayerTimesLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHijriDate() async {
    try {
      _hijriDateModel = await HijriDateService().getTodayHijriDate();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void fetchRandomVerse() async {
    try {
      final verse = await quranService.getRandomVerse();
      _quranDaily = verse;
      notifyListeners();
      print(
        "${verse.surahName} [${verse.ayahNo}]: ${verse.arabic} — ${verse.english}",
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  void fetchRandomHadith() async {
    print("Is it here?");
    try {
      final hadith = await hadithService.fetchRandomHadith();
      print("Fetched hadith: $hadith");
      _hadithDaily = hadith;
      notifyListeners();
    } catch (e) {
      print("Error $e");
    }
  }

  void startCountdown() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_times == null) return;

      final now = DateTime.now();

      final prayerMap = {
        "Fajr": _times!.fajr,
        "Dhuhr": _times!.dhuhr,
        "Asr": _times!.asr,
        "Maghrib": _times!.maghrib,
        "Isha": _times!.isha,
      };

      final prayerTimesList = prayerMap.entries.map((entry) {
        final parts = entry.value.split(":");
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return MapEntry(
          entry.key,
          DateTime(now.year, now.month, now.day, hour, minute),
        );
      }).toList();

      MapEntry<String, DateTime>? nextPrayer = prayerTimesList.firstWhere(
        (entry) => entry.value.isAfter(now),
        orElse: () {
          final parts = prayerMap["Fajr"]!.split(":");
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          return MapEntry(
            "Fajr",
            DateTime(now.year, now.month, now.day + 1, hour, minute),
          );
        },
      );

      final diff = nextPrayer.value.difference(now);
      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

      _countdownText = "$hours:$minutes:$seconds";
      _nextPrayerText = nextPrayer.key;

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  void checkIfShouldAskLocation() {
    if (times == null && !_isPrayerTimesLoading) {
      _shouldAskLocation = true;
      notifyListeners();
    }
  }

  void setLocationAsked() {
    _shouldAskLocation = false;
    notifyListeners();
  }
}
