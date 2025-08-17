class MasjidNearbyModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> photoReference;
  final double? rating;

  MasjidNearbyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.photoReference,
    this.rating,
  });

  factory MasjidNearbyModel.fromJson(Map<String, dynamic> json) {
    return MasjidNearbyModel(
      id: json["place_id"],
      name: json["name"],
      address: json["vicinity"] ?? "Unknown Address",
      latitude: json["geometry"]["location"]["lat"],
      longitude: json["geometry"]["location"]["lng"],
      photoReference:
          (json['photos'] as List<dynamic>?)
              ?.map((p) => p['photo_reference'] as String)
              .toList() ??
          [],
      rating: json["rating"]?.toDouble(),
    );
  }
}

class LatLng {
  final double lat;
  final double lng;
  LatLng(this.lat, this.lng);
}
