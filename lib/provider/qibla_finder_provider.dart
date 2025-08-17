import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ramadhan_companion_app/service/masjid_nearby_service.dart';

class QiblaProvider extends ChangeNotifier {
  final _masjidService = MasjidNearbyService();

  double? _bearing;
  bool _isLoading = false;
  String? _error;

  double? get bearing => _bearing;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchQibla(String city, String country) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final coords = await _masjidService.getLatLngFromAddress(city, country);
      _bearing = calculateQiblaDirection(coords.lat, coords.lng);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  /// Calculates the bearing (degrees from North) towards the Kaaba
  double calculateQiblaDirection(double userLat, double userLng) {
    final userLatRad = _degToRad(userLat);
    final userLngRad = _degToRad(userLng);
    final kaabaLatRad = _degToRad(kaabaLat);
    final kaabaLngRad = _degToRad(kaabaLng);

    final diffLng = kaabaLngRad - userLngRad;

    final y = sin(diffLng);
    final x =
        cos(userLatRad) * tan(kaabaLatRad) - sin(userLatRad) * cos(diffLng);

    final bearingRad = atan2(y, x);
    final bearingDeg = (_radToDeg(bearingRad) + 360) % 360;

    return bearingDeg;
  }

  double _degToRad(double deg) => deg * pi / 180.0;
  double _radToDeg(double rad) => rad * 180.0 / pi;
}
