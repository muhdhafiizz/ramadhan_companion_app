import 'package:flutter/material.dart';

class VerseDetailView extends StatelessWidget {
  final String type; 
  final dynamic verse; 

  const VerseDetailView({super.key, required this.type, required this.verse});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context, type), 
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: type == "quran"
                      ? _buildQuranDetail()
                      : _buildHadithDetail(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuranDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          verse.arabic,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 20),
        Text(
          verse.english,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 20),
        Text(
          "${verse.surahName} : ${verse.ayahNo}",
          style: const TextStyle(fontWeight: FontWeight.w600),
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
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 20),
        Text(
          verse.hadithEnglish,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 20),
        Text(
          "${verse.bookSlug} : ${verse.volume}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

Widget _buildAppBar(BuildContext context, String type) {
  return Row(
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
  );
}
