import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:ramadhan_companion_app/service/masjid_nearby_service.dart';

class QiblaProvider extends ChangeNotifier {
  final _masjidService = MasjidNearbyService();

  double? _qiblaBearing;
  double? _deviceHeading;
  bool _isLoading = false;
  String? _error;

  bool _wasAligned = false;
  StreamSubscription<CompassEvent>? _compassSubscription;

  double? get qiblaBearing => _qiblaBearing;
  double? get deviceHeading => _deviceHeading;
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  bool get isAligned {
    if (_qiblaBearing == null || _deviceHeading == null) return false;
    final diff = (_qiblaBearing! - _deviceHeading!).abs();
    return diff < 10 || (360 - diff) < 10;
  }

  Future<void> fetchQibla(String city, String country) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final coords = await _masjidService.getLatLngFromAddress(city, country);
      _qiblaBearing = calculateQiblaDirection(coords.lat, coords.lng);

      _compassSubscription = FlutterCompass.events?.listen((event) {
        _deviceHeading = event.heading;

        if (isAligned && !_wasAligned) {
          HapticFeedback.mediumImpact();
          _wasAligned = true;
        } else if (!isAligned && _wasAligned) {
          _wasAligned = false;
        }

        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }
}
