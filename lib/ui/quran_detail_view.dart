import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadhan_companion_app/provider/bookmark_provider.dart';
import 'package:ramadhan_companion_app/provider/quran_detail_provider.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';
import 'package:ramadhan_companion_app/widgets/custom_audio_snackbar.dart';
import 'package:ramadhan_companion_app/widgets/custom_pill_snackbar.dart';
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';
import 'package:ramadhan_companion_app/widgets/shimmer_loading.dart';
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
                label: "Search verse or verse number",
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
                          ? provider.verses.length + 1
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
                        final expanded = provider.isExpanded(verseNum);
                        final tafsirText = provider.getTafsir(verseNum);

                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                verse["arabic"]!,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'AmiriQuran',
                                  fontSize: provider.arabicFontSize,
                                  fontWeight: FontWeight.bold,
                                  height: 2.5,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                verse["translation"]!,
                                style: TextStyle(
                                  fontSize: provider.translationFontSize,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // === Actions row ===
                              Row(
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
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () =>
                                        provider.toggleTafsir(verseNum),
                                    child: Row(
                                      children: [
                                        Icon(
                                          expanded
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          color: Colors.purple,
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          "Tafsir",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // === Tafsir content ===
                              if (expanded)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: tafsirText == null
                                      ? Center(
                                          child: _buildShimmerLoading(),
                                        )
                                      : Text(
                                          tafsirText,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            height: 1.5,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                ),

                              const SizedBox(height: 5),
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
  final provider = context.watch<QuranDetailProvider>();

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
        onTap: () => _showFontSizeAdjuster(provider, context),
        child: Image.asset(
          'assets/icon/slider_filled_icon.png',
          width: 24,
          height: 24,
        ),
      ),

      SizedBox(width: 10),
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

Widget _buildShimmerLoading() {
  return Column(
    children: [
      ShimmerLoadingWidget(height: 20, width: double.infinity),
      SizedBox(height: 5),
      ShimmerLoadingWidget(height: 20, width: double.infinity),
      SizedBox(height: 5),
      ShimmerLoadingWidget(height: 20, width: double.infinity),
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

void _showFontSizeAdjuster(QuranDetailProvider provider, BuildContext context) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return ChangeNotifierProvider.value(
        value: provider,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Adjust Font Size",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              const Text("Arabic Font"),
              Consumer<QuranDetailProvider>(
                builder: (context, provider, _) {
                  return Slider(
                    value: provider.arabicFontSize,
                    min: 18,
                    max: 40,
                    activeColor: Colors.black,
                    inactiveColor: AppColors.betterGray.withOpacity(1),
                    divisions: 4,
                    label: "${provider.arabicFontSize.toInt()}",
                    onChanged: provider.setArabicFontSize,
                  );
                },
              ),

              const SizedBox(height: 10),

              const Text("Translation Font"),
              Consumer<QuranDetailProvider>(
                builder: (context, provider, _) {
                  return Slider(
                    value: provider.translationFontSize,
                    min: 12,
                    max: 30,
                    activeColor: Colors.black,
                    inactiveColor: AppColors.betterGray.withOpacity(1),
                    divisions: 4,
                    label: "${provider.translationFontSize.toInt()}",
                    onChanged: provider.setTranslationFontSize,
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
