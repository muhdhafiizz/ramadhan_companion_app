import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadhan_companion_app/provider/bookmark_provider.dart';
import 'package:ramadhan_companion_app/provider/quran_detail_provider.dart';
import 'package:ramadhan_companion_app/widgets/custom_pill_snackbar.dart';
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';

class SurahDetailView extends StatelessWidget {
  final int surahNumber;
  final int? initialVerse;

  const SurahDetailView({
    super.key,
    required this.surahNumber,
    this.initialVerse,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuranDetailProvider(surahNumber),
      builder: (context, child) {
        return _SurahDetailBody(
          surahNumber: surahNumber,
          initialVerse: initialVerse,
        );
      },
    );
  }
}

class _SurahDetailBody extends StatelessWidget {
  final int surahNumber;
  final int? initialVerse;

  const _SurahDetailBody({required this.surahNumber, this.initialVerse});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildAppBar(context, surahNumber),
              const SizedBox(height: 10),
              CustomTextField(
                label: "Search related verse",
                onChanged: (val) {
                  context.read<QuranDetailProvider>().search(val);
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Consumer<QuranDetailProvider>(
                  builder: (context, provider, _) {
                    final verses = provider.verses;

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: verses.length,
                      itemBuilder: (context, index) {
                        final verse = verses[index];
                        final verseNum = int.parse(verse["number"]!);

                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                verse["arabic"]!,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontFamily: 'AmiriQuran',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  height: 2.5,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                verse["translation"]!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: _buildBookmark(
                                  context,
                                  surahNumber,
                                  verseNum,
                                ),
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      },
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(surahNameEnglish, style: const TextStyle(fontSize: 14)),
        ],
      ),
    ],
  );
}

Widget _buildBookmark(BuildContext context, int surahNumber, int verseNum) {
  final bookmarkProvider = Provider.of<BookmarkProvider>(context);

  return IconButton(
    icon: Image.asset(
      bookmarkProvider.isBookmarked(surahNumber, verseNum)
          ? "assets/icon/bookmark_icon.png"
          : "assets/icon/bookmark_empty_icon.png",
      width: 24,
      height: 24,
    ),
    onPressed: () {
      bookmarkProvider.toggleBookmark(surahNumber, verseNum);

      bookmarkProvider.isBookmarked(surahNumber, verseNum)
          ? CustomPillSnackbar.show(
              context,
              message: "✅ Added to bookmark",
              backgroundColor: Colors.black,
            )
          : CustomPillSnackbar.show(
              context,
              message: "❌ Removed from bookmark",
              backgroundColor: Colors.black,
            );
    },
  );
}
