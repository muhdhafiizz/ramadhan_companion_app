import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;

class SurahDetailView extends StatelessWidget {
  final int surahNumber;
  const SurahDetailView({super.key, required this.surahNumber});

  @override
  Widget build(BuildContext context) {
    final verseCount = quran.getVerseCount(surahNumber);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildAppBar(context, surahNumber),
              Expanded(
                child: ListView.builder(
                  itemCount: verseCount,
                  itemBuilder: (context, index) {
                    final verseNum = index + 1;
                    final arabic = quran.getVerse(surahNumber, verseNum, verseEndSymbol: true);
                    final translation = quran.getVerseTranslation(
                      surahNumber,
                      verseNum,
                    );

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            arabic,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'AmiriQuran',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            translation,
                            style: const TextStyle(fontSize: 16),
                          ),
                          Divider(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildAppBar(BuildContext context, int surahNumber) {
  final surahNameArabic = quran.getSurahName(surahNumber);
  final surahNameEnglish = quran.getSurahNameEnglish(surahNumber);

  return Row(
    children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            surahNameArabic,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, ),
          ),
          Text(
            surahNameEnglish,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    ],
  );
}
