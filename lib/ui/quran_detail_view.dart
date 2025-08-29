import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadhan_companion_app/provider/bookmark_provider.dart';
import 'package:ramadhan_companion_app/provider/quran_detail_provider.dart';
import 'package:ramadhan_companion_app/widgets/custom_audio_snackbar.dart';
import 'package:ramadhan_companion_app/widgets/custom_pill_snackbar.dart';
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
      create: (_) =>
          QuranDetailProvider(surahNumber, initialVerse: initialVerse),
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
    final provider = context.watch<QuranDetailProvider>();

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
                onChanged: provider.search,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Stack(
                  children: [
                    ScrollablePositionedList.builder(
                      itemScrollController: provider.itemScrollController,
                      itemPositionsListener: provider.itemPositionsListener,
                      itemCount: (surahNumber != 1 && surahNumber != 9)
                          ? provider.verses.length +
                                1 
                          : provider.verses.length, 
                      itemBuilder: (context, index) {
                        if (index == 0 &&
                            surahNumber != 1 &&
                            surahNumber != 9) {
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              quran.basmala,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'AmiriQuran',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 2.5,
                              ),
                            ),
                          );
                        }

                        final verseIndex =
                            (surahNumber != 1 && surahNumber != 9)
                            ? index - 1
                            : index;

                        final verse = provider.verses[verseIndex];
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
                                child: Row(
                                  children: [
                                    _buildBookmark(
                                      context,
                                      surahNumber,
                                      verseNum,
                                    ),
                                    const SizedBox(width: 10),
                                    _buildVerseAudio(
                                      provider,
                                      surahNumber,
                                      verseNum,
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      },
                    ),

                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Column(
                        children: [
                          if (provider.showScrollUp)
                            FloatingActionButton(
                              shape: const CircleBorder(),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              mini: true,
                              heroTag: "scroll_up",
                              onPressed: provider.scrollToTop,
                              child: const Icon(Icons.arrow_upward),
                            ),
                          const SizedBox(height: 10),
                          if (provider.showScrollDown)
                            FloatingActionButton(
                              shape: const CircleBorder(),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              mini: true,
                              heroTag: "scroll_down",
                              onPressed: provider.scrollToBottom,
                              child: const Icon(Icons.arrow_downward),
                            ),
                        ],
                      ),
                    ),
                    Positioned(bottom: 20, right: 90, child: AudioPillWidget()),
                  ],
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
  final provider = context.read<QuranDetailProvider>();

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
      const Spacer(),
      GestureDetector(
        onTap: () {
          provider.playAudio();
        },
        child: Image.asset(
          'assets/icon/volume_icon.png',
          width: 24,
          height: 24,
        ),
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

Widget _buildVerseAudio(
  QuranDetailProvider provider,
  int surahNumber,
  int verseNumber,
) {
  final isPlayingThisVerse =
      provider.playingVerse == verseNumber && provider.isVersePlaying;

  return GestureDetector(
    onTap: () {
      if (isPlayingThisVerse) {
        provider.pauseVerseAudio();
      } else {
        provider.playAudioVerse(verse: verseNumber);
      }
    },
    child: Image.asset(
      isPlayingThisVerse
          ? 'assets/icon/volume_icon.png'
          : 'assets/icon/volume_outlined_icon.png',
      height: 24,
      width: 24,
    ),
  );
}
