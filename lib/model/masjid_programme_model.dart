import 'dart:typed_data';

class MasjidProgramme {
  final String masjidName;
  final String title;
  final DateTime dateTime;
  final bool isOnline;
  final String? location;
  final String? joinLink;
  final String? posterUrl; // Firestore string (Base64 or URL)
  final Uint8List? posterBytes; // 🔥 cached decoded bytes

  MasjidProgramme({
    required this.masjidName,
    required this.title,
    required this.dateTime,
    required this.isOnline,
    this.location,
    this.joinLink,
    this.posterUrl,
    this.posterBytes,
  });
}
