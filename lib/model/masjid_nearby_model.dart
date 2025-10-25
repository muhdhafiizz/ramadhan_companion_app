class MasjidNearbyModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final List<String> photoReference;
  final double? rating;
  final String? wikidataId; // 👈 add this

  MasjidNearbyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.photoReference,
    this.rating,
    this.wikidataId,
  });

  factory MasjidNearbyModel.fromJson(Map<String, dynamic> json) {
    return MasjidNearbyModel(
      id: json["place_id"] ?? "",
      name: json["name"] ?? "Unknown Masjid",
      address: json["formatted"] ?? "Unknown Address",
      city: json["city"] ?? json["suburb"] ?? json["town"] ?? "",
      state: json["state"] ?? "",
      latitude: json["lat"] ?? 0,
      longitude: json["lon"] ?? 0,
      photoReference: [],
      rating: null,
      wikidataId: json["wiki_and_media"]?["wikidata"] ??
          json["wikidata"], // 👈 capture Wikidata ID
    );
  }
}


class LatLng {
  final double lat;
  final double lng;
  LatLng(this.lat, this.lng);
}
