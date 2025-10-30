import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadhan_companion_app/provider/quran_provider.dart';
import 'package:ramadhan_companion_app/ui/quran_detail_view.dart';
import 'package:ramadhan_companion_app/ui/quran_page_view.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';

class QuranView extends StatelessWidget {
  const QuranView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranProvider>();
    final pages = provider.getQuranPages();
    final pageNumbers = pages.keys.toList()..sort();

    return DefaultTabController(
      length: 2,
      initialIndex: provider.showByPage ? 1 : 0,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 10),
                _buildToggleSurahPage(context, provider),
                const SizedBox(height: 10),

                if (!provider.showByPage)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomTextField(
                      label: "Search Surah",
                      onChanged: provider.updateQuery,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomTextField(
                      label: "Search Page or Juz",
                      onChanged: provider.updateQuery,
                      keyboardType: TextInputType.number,
                    ),
                  ),

                Expanded(
                  child: Stack(
                    children: [
                      // 👇 Show by Surah or by Page
                      provider.showByPage
                          ? _buildPageList(
                              context,
                              pageNumbers,
                              pages,
                              provider,
                            )
                          : _buildSurahList(context, provider),

                      // ⬆️⬇️ Floating Buttons
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
                                heroTag: "scroll_up_quran",
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
                                heroTag: "scroll_down_quran",
                                onPressed: provider.scrollToBottom,
                                child: const Icon(Icons.arrow_downward),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahList(BuildContext context, QuranProvider provider) {
    return ListView.builder(
      controller: provider.surahScrollController,
      itemCount: provider.filteredSurahs.length,
      itemBuilder: (context, i) {
        final index = provider.filteredSurahs[i];
        return ListTile(
          title: Text(
            "$index. ${quran.getSurahName(index)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("Verses: ${quran.getVerseCount(index)}"),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SurahDetailView(surahNumber: index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPageList(
    BuildContext context,
    List<int> pageNumbers,
    Map<int, List<Map<String, int>>> pages,
    QuranProvider provider,
  ) {
    return ListView.builder(
      controller: provider.pageScrollController,
      itemCount: provider.filteredPages.length,
      itemBuilder: (context, i) {
        final page = provider.filteredPages[i];
        final first = pages[page]!.first;
        final last = pages[page]!.last;
        final startSurah = quran.getSurahName(first['surah']!);
        final endSurah = quran.getSurahName(last['surah']!);

        return ListTile(
          title: Text(
            "Page $page",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("$startSurah → $endSurah"),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuranPageView(pageNumber: page),
              ),
            );
          },
        );
      },
    );
  }

  // 🔹 Simple Back Header
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 10),
        const Text(
          "Qur'an",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ],
    );
  }

  Widget _buildToggleSurahPage(BuildContext context, QuranProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.betterGray.withOpacity(1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        onTap: (index) {
          provider.setViewMode(index == 1);
        },
        indicator: BoxDecoration(
          color: Colors.black,
          borderRadius: const BorderRadius.all(Radius.circular(25)),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: "By Surah"),
          Tab(text: "By Page"),
        ],
      ),
    );
  }
}
