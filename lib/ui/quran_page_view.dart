import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadhan_companion_app/provider/bookmark_provider.dart';
import 'package:ramadhan_companion_app/provider/quran_provider.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';
import 'package:ramadhan_companion_app/widgets/custom_pill_snackbar.dart';

class QuranPageView extends StatelessWidget {
  final int pageNumber;
  const QuranPageView({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranProvider>();
    final pages = provider.getQuranPages();
    final allPages = pages.keys.toList()..sort();
    final isFirstPage = pageNumber == allPages.first;
    final isLastPage = pageNumber == allPages.last;
    final verses = pages[pageNumber]!;
    final firstVerse = verses.first;
    final surahNumber = firstVerse['surah']!;
    final verseNumber = firstVerse['verse']!;
    final juzNumber = quran.getJuzNumber(surahNumber, verseNumber);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildAppBar(context, juzNumber, pageNumber),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  final offsetAnimation =
                      Tween<Offset>(
                        begin: Offset(provider.showByPage ? 1 : -1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                      );
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                child: _buildPageContent(
                  verses,
                  key: ValueKey(pageNumber),
                  provider,
                ),
              ),
            ),
            _buildBottomNav(
              context,
              pageNumber: pageNumber,
              isFirstPage: isFirstPage,
              isLastPage: isLastPage,
              allPages: allPages,
              provider: provider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(
    BuildContext context, {
    required int pageNumber,
    required bool isFirstPage,
    required bool isLastPage,
    required List<int> allPages,
    required QuranProvider provider,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isFirstPage)
            ElevatedButton.icon(
              style: whiteButtonStyle,
              onPressed: () {
                _navigateWithAnimation(
                  context,
                  QuranPageView(pageNumber: pageNumber - 1),
                  isNext: false,
                  provider: provider,
                );
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              label: const Text("Previous"),
            )
          else
            const SizedBox(width: 120),

          GestureDetector(
            onTap: () => showPageList(context, provider),
            child: Text(
              "$pageNumber / ${allPages.last}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
          ),

          if (!isLastPage)
            ElevatedButton.icon(
              style: blackButtonStyle,
              onPressed: () {
                _navigateWithAnimation(
                  context,
                  QuranPageView(pageNumber: pageNumber + 1),
                  isNext: true,
                  provider: provider,
                );
              },
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              label: const Text("Next"),
            )
          else
            const SizedBox(width: 120),
        ],
      ),
    );
  }

  void _navigateWithAnimation(
    BuildContext context,
    QuranPageView newPage, {
    required bool isNext,
    required QuranProvider provider,
  }) {
    provider.setViewMode(isNext);
    provider.setCurrentPage(newPage.pageNumber);
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => newPage,
        transitionDuration: Duration.zero,
      ),
    );
  }

  void showPageList(BuildContext context, QuranProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final TextEditingController searchController = TextEditingController();
        final ValueNotifier<String> searchQuery = ValueNotifier('');

        final double sheetHeight = MediaQuery.of(context).size.height * 0.75;

        return SizedBox(
          height: sheetHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: SafeArea(
              child: Column(
                children: [
                  // Top drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const Text(
                    "Select Page",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // 🔍 Search bar
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search by page number or surah...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => searchQuery.value = value,
                  ),
                  const SizedBox(height: 15),

                  // 📖 Page list
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: searchQuery,
                      builder: (_, query, __) {
                        final allPages = List.generate(604, (i) => i + 1);

                        final filteredPages = allPages.where((page) {
                          final firstVerse = quran.getPageData(page).first;
                          final lastVerse = quran.getPageData(page).last;

                          final startSurah = quran.getSurahName(
                            firstVerse['surah']!,
                          );
                          final endSurah = quran.getSurahName(
                            lastVerse['surah']!,
                          );

                          return page.toString().contains(query) ||
                              startSurah.contains(query) ||
                              endSurah.contains(query) ||
                              startSurah.toLowerCase().contains(
                                query.toLowerCase(),
                              ) ||
                              endSurah.toLowerCase().contains(
                                query.toLowerCase(),
                              );
                        }).toList();

                        return ListView.builder(
                          itemCount: filteredPages.length,
                          itemBuilder: (context, index) {
                            final page = filteredPages[index];
                            final firstVerse = quran.getPageData(page).first;
                            final lastVerse = quran.getPageData(page).last;

                            final startSurah = quran.getSurahName(
                              firstVerse['surah']!,
                            );
                            final endSurah = quran.getSurahName(
                              lastVerse['surah']!,
                            );

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                child: Text(
                                  page.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                "Page $page",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("$startSurah → $endSurah"),
                              onTap: () {
                                Navigator.pop(context); // close bottom sheet
                                _navigateWithAnimation(
                                  context,
                                  QuranPageView(pageNumber: page),
                                  isNext: page > provider.currentPageNumber,
                                  provider: provider,
                                );
                              },
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
      },
    );
  }
}

Widget _buildPageContent(
  List<Map<String, int>> verses,
  QuranProvider provider, {
  Key? key,
}) {
  return ListView.builder(
    key: key,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: verses.length,
    itemBuilder: (context, i) {
      final surah = verses[i]['surah']!;
      final verse = verses[i]['verse']!;
      final text = quran.getVerse(surah, verse, verseEndSymbol: true);
      final translation = quran.getVerseTranslation(
        surah,
        verse,
        translation: provider.selectedTranslation,
      );
      final isFirstVerseOfSurah = verse == 1;
      final showBasmala = isFirstVerseOfSurah && surah != 9 && surah != 1;

      bool isNewSurah = false;
      if (i > 0 && verses[i - 1]['surah'] != surah) {
        isNewSurah = true;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isNewSurah) const Divider(thickness: 2, height: 30),

          if (isFirstVerseOfSurah) _buildSurahHeader(surah),

          if (showBasmala)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                quran.basmala,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'AmiriQuran',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'AmiriQuran',
                fontSize: provider.arabicFontSize,
                height: 2.2,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              translation,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: provider.translationFontSize,
                color: Colors.grey.shade800,
                height: 1.6,
              ),
            ),
          ),
          const Divider(),
        ],
      );
    },
  );
}

// 🕌 Surah header
Widget _buildSurahHeader(int surahNumber) {
  final name = quran.getSurahName(surahNumber);
  final arabicName = quran.getSurahNameArabic(surahNumber);
  final verseCount = quran.getVerseCount(surahNumber);
  final placeOfRevelation = quran.getPlaceOfRevelation(surahNumber);

  return Column(
    children: [
      const SizedBox(height: 10),
      Center(
        child: Text(
          "$name ($arabicName)",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        "Verses: $verseCount | $placeOfRevelation",
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      const SizedBox(height: 10),
    ],
  );
}

Widget _buildAppBar(BuildContext context, int juzNumber, int pageNumber) {
  final bookmarkProvider = context.watch<BookmarkProvider>();
  final quranProvider = context.watch<QuranProvider>();

  return Row(
    children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
      SizedBox(width: 5),
      Text(
        'Juz $juzNumber',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      Spacer(),
      GestureDetector(
        onTap: () => showQuranSettingsBottomSheet(context, quranProvider),
        child: Icon(
          Icons.menu_outlined,
          color: AppColors.violet.withOpacity(1),
        ),
        // Image.asset(
        //   'assets/icon/slider_filled_icon.png',
        //   width: 24,
        //   height: 24,
        // ),
      ),
      IconButton(
        icon: Image.asset(
          bookmarkProvider.isPageBookmarked(pageNumber)
              ? "assets/icon/bookmark_icon.png"
              : "assets/icon/bookmark_empty_icon.png",
          width: 20,
          height: 20,
        ),
        onPressed: () {
          bookmarkProvider.togglePageBookmark(pageNumber);
          bookmarkProvider.isPageBookmarked(pageNumber)
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
      ),
    ],
  );
}

ButtonStyle get whiteButtonStyle => ElevatedButton.styleFrom(
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: const BorderSide(color: Colors.black26),
  ),
);

ButtonStyle get blackButtonStyle => ElevatedButton.styleFrom(
  backgroundColor: Colors.black,
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
);

Future<void> showQuranSettingsBottomSheet(
  BuildContext context,
  QuranProvider provider,
) async {
  return showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return ChangeNotifierProvider.value(
        value: provider,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                "Adjust Quran Settings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Translation Language Selector
              const Text(
                "Translation Language",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Consumer<QuranProvider>(
                builder: (_, provider, __) {
                  final selectedLang = provider.availableTranslations
                      .firstWhere(
                        (lang) => lang["value"] == provider.selectedTranslation,
                        orElse: () => provider.availableTranslations.first,
                      );

                  return InkWell(
                    onTap: () => _showTranslationSelector(provider, context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedLang["name"]),
                          const Icon(Icons.keyboard_arrow_down_rounded),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // Arabic Font Size
              const Text(
                "Arabic Font Size",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Consumer<QuranProvider>(
                builder: (_, provider, __) {
                  return Slider(
                    value: provider.arabicFontSize,
                    min: 18,
                    max: 40,
                    divisions: 4,
                    activeColor: Colors.black,
                    inactiveColor: Colors.grey.shade300,
                    label: "${provider.arabicFontSize.toInt()}",
                    onChanged: provider.setArabicFontSize,
                  );
                },
              ),

              const SizedBox(height: 15),

              // Translation Font Size
              const Text(
                "Translation Font Size",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Consumer<QuranProvider>(
                builder: (_, provider, __) {
                  return Slider(
                    value: provider.translationFontSize,
                    min: 12,
                    max: 30,
                    divisions: 4,
                    activeColor: Colors.black,
                    inactiveColor: Colors.grey.shade300,
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

void _showTranslationSelector(QuranProvider provider, BuildContext context) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Text(
              "Select Translation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...provider.availableTranslations.map((lang) {
              final isSelected = lang["value"] == provider.selectedTranslation;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  lang["name"],
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.grey.shade700,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  provider.setTranslationLanguage(lang["value"]);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      );
    },
  );
}
