class QuranDailyModel {
  final String surahName;
  final int ayahNo;
  final String arabic;
  final String english;

  QuranDailyModel({
    required this.surahName,
    required this.ayahNo,
    required this.arabic,
    required this.english,
  });

  factory QuranDailyModel.fromJson(Map<String, dynamic> json) {
    return QuranDailyModel(
      surahName: json['surahName'],
      ayahNo: json['ayahNo'],
      arabic: json['arabic1'],
      english: json['english'],
    );
  }
}
