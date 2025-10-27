import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ramadhan_companion_app/model/masjid_account_model.dart';
import 'package:ramadhan_companion_app/model/masjid_nearby_model.dart';
import 'package:ramadhan_companion_app/service/masjid_nearby_service.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

class MasjidNearbyProvider extends ChangeNotifier {
  final MasjidNearbyService _masjidService = MasjidNearbyService();

  List<MasjidNearbyModel> _masjids = [];
  MasjidNearbyModel? _selectedMasjid;

  bool _isLoading = false;
  String? _errorMessage;

  double? originLat;
  double? originLng;
  String? originCity;
  String? originCountry;

  List<MasjidNearbyModel> get masjids => _masjids;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MasjidNearbyModel? get selectedMasjid => _selectedMasjid;

  Future<void> fetchMasjidsFromAddress(String city, String country) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final coords = await _masjidService.getLatLngFromAddress(city, country);

      originLat = coords.lat;
      originLng = coords.lng;
      originCity = city;
      originCountry = country;

      _masjids = await _masjidService.getNearbyMasjids(coords.lat, coords.lng);

      _masjids.sort((a, b) {
        final distA = calculateDistance(
          originLat!,
          originLng!,
          a.latitude,
          a.longitude,
        );
        final distB = calculateDistance(
          originLat!,
          originLng!,
          b.latitude,
          b.longitude,
        );
        return distA.compareTo(distB);
      });
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMasjidsFromCoordinates(double lat, double lng) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      originLat = lat;
      originLng = lng;

      _masjids = await _masjidService.getNearbyMasjids(lat, lng);

      _masjids.sort((a, b) {
        final distA = calculateDistance(
          originLat!,
          originLng!,
          a.latitude,
          a.longitude,
        );
        final distB = calculateDistance(
          originLat!,
          originLng!,
          b.latitude,
          b.longitude,
        );
        return distA.compareTo(distB);
      });
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  set selectedMasjid(MasjidNearbyModel? m) {
    _selectedMasjid = m;
    notifyListeners();
  }

  Future<void> openMap(double lat, double lng) async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    final wazeUrl = Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes');

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(wazeUrl)) {
        await launchUrl(wazeUrl, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch any map application.");
        throw 'Could not launch map';
      }
    } catch (e) {
      debugPrint("Error launching map: $e");
    }
  }

  Future<List<MasjidAccount>> loadMasjidAccounts(BuildContext context) async {
    final String data = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/data/masjid_account.json');
    final List<dynamic> jsonResult = json.decode(data);
    return jsonResult.map((e) => MasjidAccount.fromJson(e)).toList();
  }

  MasjidAccount? findClosestMatch(
    String googleName,
    List<MasjidAccount> accounts,
  ) {
    String normalize(String input) {
      return input
          .toLowerCase()
          .replaceAll(RegExp(r'\bmasjid\b'), '')
          .replaceAll(RegExp(r'\bmosque\b'), '')
          .trim();
    }

    final query = normalize(googleName);

    for (final account in accounts) {
      final name = normalize(account.masjidName);

      if (name == query) {
        return account;
      }
    }

    return null;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371;

    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);
}
