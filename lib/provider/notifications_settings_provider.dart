import 'package:flutter/foundation.dart';
import 'package:ramadhan_companion_app/provider/prayer_times_provider.dart';
import 'package:ramadhan_companion_app/ui/prayer_times_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  bool _prayerNotificationsEnabled = true;
  bool _sadaqahNotificationsEnabled = true;
  bool _initialized = false;

  bool get prayerNotificationsEnabled => _prayerNotificationsEnabled;
  bool get sadaqahNotificationsEnabled => _sadaqahNotificationsEnabled;
  bool get initialized => _initialized;

  /// Load saved settings (or set defaults on first launch)
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _prayerNotificationsEnabled =
        prefs.getBool('prayer_notifications') ?? true; // auto-on default
    _sadaqahNotificationsEnabled =
        prefs.getBool('sadaqah_notifications') ?? true; // auto-on default
    _initialized = true;
    notifyListeners();
  }

  /// Toggle prayer notifications
  Future<void> togglePrayerNotifications(bool value, PrayerTimesProvider prayerProvider) async {
  _prayerNotificationsEnabled = value;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('prayer_notifications', value);

  if (value) {
    await schedulePrayerNotifications(prayerProvider);
  } else {
    await cancelPrayerNotifications();
  }

  notifyListeners();
}


  /// Toggle sadaqah notifications
  Future<void> toggleSadaqahNotifications(bool value) async {
    _sadaqahNotificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sadaqah_notifications', value);

    if (value) {
      await scheduleSadaqahReminder();
    } else {
      await cancelSadaqahNotifications();
    }

    notifyListeners();
  }
}
