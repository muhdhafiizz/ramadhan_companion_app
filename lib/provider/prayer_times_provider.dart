import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ramadhan_companion_app/model/prayer_times_model.dart';
import 'package:ramadhan_companion_app/service/prayer_times_service.dart';

class PrayerTimesProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _shouldAskLocation = false;
  String? _error;
  String? _city;
  String? _country;
  PrayerTimesModel? _times;

  bool get isLoading => _isLoading;
  bool get shouldAskLocation => _shouldAskLocation;
  String? get error => _error;
  String? get city => _city;
  String? get country => _country;
  PrayerTimesModel? get times => _times;

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
    _isLoading = true;
    _error = null;
    _city = city;
    _country = country;
    notifyListeners();

    try {
      _times = await PrayerTimesService().getPrayerTimes(city, country);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  void checkIfShouldAskLocation() {
    if (times == null && !isLoading) {
      _shouldAskLocation = true;
      notifyListeners();
    }
  }

  void setLocationAsked() {
    _shouldAskLocation = false;
    notifyListeners();
  }
}
