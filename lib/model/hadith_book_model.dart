class HadithBook {
  final int id;
  final String bookName;
  final String writerName;
  final String? aboutWriter;
  final String writerDeath;
  final String bookSlug;
  final String hadithsCount;
  final String chaptersCount;

  HadithBook({
    required this.id,
    required this.bookName,
    required this.writerName,
    this.aboutWriter,
    required this.writerDeath,
    required this.bookSlug,
    required this.hadithsCount,
    required this.chaptersCount,
  });

  factory HadithBook.fromJson(Map<String, dynamic> json) {
    return HadithBook(
      id: json['id'] ?? 0,
      bookName: json['bookName'] ?? '',
      writerName: json['writerName'] ?? '',
      aboutWriter: json['aboutWriter'],
      writerDeath: json['writerDeath'] ?? '',
      bookSlug: json['bookSlug'] ?? '',
      hadithsCount:
          (json['hadiths_count'] ?? json['hadithsCount'] ?? '0').toString(),
      chaptersCount:
          (json['chapters_count'] ?? json['chaptersCount'] ?? '0').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookName': bookName,
      'writerName': writerName,
      'aboutWriter': aboutWriter,
      'writerDeath': writerDeath,
      'bookSlug': bookSlug,
      'hadiths_count': hadithsCount,
      'chapters_count': chaptersCount,
    };
  }
}

class HadithChapter {
  final int id;
  final String chapterNumber;
  final String chapterEnglish;
  final String chapterUrdu;
  final String chapterArabic;
  final String bookSlug;

  HadithChapter({
    required this.id,
    required this.chapterNumber,
    required this.chapterEnglish,
    required this.chapterUrdu,
    required this.chapterArabic,
    required this.bookSlug,
  });

  factory HadithChapter.fromJson(Map<String, dynamic> json) {
    return HadithChapter(
      id: json['id'] ?? 0,
      chapterNumber:
          json['chapterNumber']?.toString() ?? json['chapter_number']?.toString() ?? '',
      chapterEnglish: json['chapterEnglish'] ?? '',
      chapterUrdu: json['chapterUrdu'] ?? '',
      chapterArabic: json['chapterArabic'] ?? '',
      bookSlug: json['bookSlug'] ?? json['book_slug'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapterNumber': chapterNumber,
      'chapterEnglish': chapterEnglish,
      'chapterUrdu': chapterUrdu,
      'chapterArabic': chapterArabic,
      'bookSlug': bookSlug,
    };
  }
}

class HadithModel {
  final int id;
  final String? hadithNumber;
  final String? englishNarrator;
  final String? hadithEnglish;
  final String? hadithUrdu;
  final String? urduNarrator;
  final String? hadithArabic;
  final String? headingArabic;
  final String? headingUrdu;
  final String? headingEnglish;
  final String? chapterId;
  final String? bookSlug;
  final String? volume;
  final String? status;
  final HadithBook? book;
  final HadithChapter? chapter;

  HadithModel({
    required this.id,
    this.hadithNumber,
    this.englishNarrator,
    this.hadithEnglish,
    this.hadithUrdu,
    this.urduNarrator,
    this.hadithArabic,
    this.headingArabic,
    this.headingUrdu,
    this.headingEnglish,
    this.chapterId,
    this.bookSlug,
    this.volume,
    this.status,
    this.book,
    this.chapter,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      id: json['id'] ?? 0,
      hadithNumber: json['hadithNumber']?.toString(),
      englishNarrator: json['englishNarrator'],
      hadithEnglish: json['hadithEnglish'],
      hadithUrdu: json['hadithUrdu'],
      urduNarrator: json['urduNarrator'],
      hadithArabic: json['hadithArabic'],
      headingArabic: json['headingArabic'],
      headingUrdu: json['headingUrdu'],
      headingEnglish: json['headingEnglish'],
      chapterId: json['chapterId']?.toString(),
      bookSlug: json['bookSlug'],
      volume: json['volume']?.toString(),
      status: json['status'],
      book: json['book'] != null ? HadithBook.fromJson(json['book']) : null,
      chapter:
          json['chapter'] != null ? HadithChapter.fromJson(json['chapter']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hadithNumber': hadithNumber,
      'englishNarrator': englishNarrator,
      'hadithEnglish': hadithEnglish,
      'hadithUrdu': hadithUrdu,
      'urduNarrator': urduNarrator,
      'hadithArabic': hadithArabic,
      'headingArabic': headingArabic,
      'headingUrdu': headingUrdu,
      'headingEnglish': headingEnglish,
      'chapterId': chapterId,
      'bookSlug': bookSlug,
      'volume': volume,
      'status': status,
      'book': book?.toJson(),
      'chapter': chapter?.toJson(),
    };
  }
}
