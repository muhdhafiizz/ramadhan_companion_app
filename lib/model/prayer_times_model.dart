class PrayerTimesModel {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTimesModel({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    return PrayerTimesModel(
      fajr: timings['Fajr'],
      dhuhr: timings['Dhuhr'],
      asr: timings['Asr'],
      maghrib: timings['Maghrib'],
      isha: timings['Isha'],
    );
  }
}
