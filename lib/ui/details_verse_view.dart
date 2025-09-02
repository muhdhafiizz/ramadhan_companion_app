import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadhan_companion_app/provider/detail_verse_provider.dart';

class VerseDetailView extends StatelessWidget {
  final String type;
  final dynamic verse;

  const VerseDetailView({super.key, required this.type, required this.verse});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DailyVerseProvider(),
      child: Consumer<DailyVerseProvider>(
        builder: (context, provider, _) {
          final refs = provider.verseRefs;

          return Scaffold(
            body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar(context, type),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: type == "quran"
                            ? _buildQuranDetail(refs)
                            : _buildHadithDetail(),
                      ),
                    ),
                  ],
                ),
              ),
          );
        },
      ),
    );
  }

  Widget _buildQuranDetail(List<Map<String, int>> refs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            verse.arabic,
            style: const TextStyle(
              fontFamily: 'AmiriQuran',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 2.5,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(verse.english, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${verse.surahName} : ${verse.ayahNo}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildTitleText(type),
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: refs.length,
            itemBuilder: (context, index) {
              final surah = refs[index]["surah"]!;
              final ayah = refs[index]["ayah"]!;
              return _buildQuranVerseCard(surah, ayah);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHadithDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          verse.hadithArabic,
          style: const TextStyle(
            fontFamily: 'AmiriQuran',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 2.5,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 20),
        Text(verse.hadithEnglish, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 20),
        Text(
          "${verse.bookSlug} : ${verse.volume}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildQuranVerseCard(int surah, int ayah) {
    return Container(
      width: 350,
      margin: const EdgeInsets.only(right: 20, top: 12, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Text(
              quran.getVerse(surah, ayah),
              style: const TextStyle(
                fontFamily: 'AmiriQuran',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 2,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            quran.getVerseTranslation(surah, ayah),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            "${quran.getSurahName(surah)} : $ayah",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

Widget _buildAppBar(BuildContext context, String type) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 10),
        Text(
          type == "quran" ? "Qur'an Verse" : "Hadith",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ],
    ),
  );
}

Widget _buildTitleText(String type) {
  return Text(
    type == "quran" ? "More Verses" : "More Hadith",
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
  );
}
