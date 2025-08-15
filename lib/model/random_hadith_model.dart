class  RandomHadithModel {
  final int id;
  final String hadithNumber;
  final String englishNarrator;
  final String hadithEnglish;
  final String hadithUrdu;
  final String hadithArabic;
  final String headingEnglish;
  final String headingUrdu;
  final String headingArabic;
  final String chapterId;
  final String bookSlug;
  final String volume;
  final String status;

  RandomHadithModel({
    required this.id,
    required this.hadithNumber,
    required this.englishNarrator,
    required this.hadithEnglish,
    required this.hadithUrdu,
    required this.hadithArabic,
    required this.headingEnglish,
    required this.headingUrdu,
    required this.headingArabic,
    required this.chapterId,
    required this.bookSlug,
    required this.volume,
    required this.status,
  });

  factory RandomHadithModel.fromJson(Map<String, dynamic> json) {
    return RandomHadithModel(
      id: json['id'],
      hadithNumber: json['hadithNumber'],
      englishNarrator: json['englishNarrator'] ?? '',
      hadithEnglish: json['hadithEnglish'] ?? '',
      hadithUrdu: json['hadithUrdu'] ?? '',
      hadithArabic: json['hadithArabic'] ?? '',
      headingEnglish: json['headingEnglish'] ?? '',
      headingUrdu: json['headingUrdu'] ?? '',
      headingArabic: json['headingArabic'] ?? '',
      chapterId: json['chapterId'],
      bookSlug: json['bookSlug'],
      volume: json['volume'],
      status: json['status'],
    );
  }
}