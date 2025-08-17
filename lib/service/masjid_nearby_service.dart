import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ramadhan_companion_app/model/masjid_nearby_model.dart';
import 'package:ramadhan_companion_app/secrets/api_keys.dart';

class MasjidNearbyService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  Future<LatLng> getLatLngFromAddress(String city, String country) async {
    final address = Uri.encodeComponent("$city, $country");
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=${ApiKeys.masjidNearbyKey}",
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data["status"] == "OK") {
      final location = data["results"][0]["geometry"]["location"];
      return LatLng(location["lat"], location["lng"]);
    } else {
      throw Exception("Failed to get coordinates: ${data["status"]}");
    }
  }

  Future<List<MasjidNearbyModel>> getNearbyMasjids(
    double lat,
    double lng,
  ) async {
    final url = Uri.parse(
      "$_baseUrl/nearbysearch/json?location=$lat,$lng&radius=5000&type=mosque&key=${ApiKeys.masjidNearbyKey}",
    );

    debugPrint("Fetching nearby masjids from: $url");

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data["status"] != "OK") {
      throw Exception("Failed to fetch masjids: ${data["status"]}");
    }

    final results = data["results"] as List;

    List<MasjidNearbyModel> masjids = [];
    for (var place in results) {
      String placeId = place["place_id"];
      List<String> photos = await _fetchPlacePhotos(placeId);

      masjids.add(
        MasjidNearbyModel(
          id: placeId,
          name: place["name"],
          address: place["vicinity"] ?? "Unknown Address",
          latitude: place["geometry"]["location"]["lat"],
          longitude: place["geometry"]["location"]["lng"],
          photoReference: photos,
          rating: place["rating"]?.toDouble(),
        ),
      );
    }

    return masjids;
  }

  Future<List<String>> _fetchPlacePhotos(String placeId) async {
    final url = Uri.parse(
      "$_baseUrl/details/json?place_id=$placeId&fields=photos&key=${ApiKeys.masjidNearbyKey}",
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data["status"] != "OK") {
      return [];
    }

    final photos = data["result"]["photos"] as List<dynamic>?;

    return photos?.map((p) => p["photo_reference"] as String).toList() ?? [];
  }
}
