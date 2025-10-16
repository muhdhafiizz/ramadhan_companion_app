import 'dart:typed_data';

class MasjidProgramme {
  final String id;
  final String masjidName;
  final String title;
  final DateTime dateTime;
  final bool isOnline;
  final String? location;
  final String? joinLink;
  final String? posterUrl;
  final Uint8List? posterBytes;
  final String status;

  MasjidProgramme({
    required this.id,
    required this.masjidName,
    required this.title,
    required this.dateTime,
    required this.isOnline,
    this.location,
    this.joinLink,
    this.posterUrl,
    this.posterBytes,
    this.status = 'pending',
  });
}

