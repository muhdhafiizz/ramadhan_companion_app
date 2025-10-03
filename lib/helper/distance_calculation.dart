import 'dart:math';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371;

  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c; 
}

double _deg2rad(double deg) => deg * (pi / 180);

String formatCurrency(double value) {
  return value.toStringAsFixed(2);
}

String formatUrl(String url) {
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    return 'https://$url';
  }
  return url;
}

DateTime parsePrayerTime(String timeString) {
  final now = DateTime.now();
  final parts = timeString.split(":");
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);

  var scheduled = DateTime(now.year, now.month, now.day, hour, minute);

  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }

  return scheduled;
}

String cleanArabic(String text) {
  // Remove any trailing Arabic verse numbers (in Unicode range)
  return text.replaceAll(RegExp(r'﴾.*﴿'), '').trim();
}




