import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/hadith_chapters_provider.dart';
import 'package:ramadhan_companion_app/ui/hadith_view.dart';
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';
import 'package:ramadhan_companion_app/widgets/shimmer_loading.dart';

class HadithChaptersView extends StatelessWidget {
  final String bookSlug;

  const HadithChaptersView({super.key, required this.bookSlug});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HadithChaptersProvider()..loadChapters(bookSlug),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _buildAppBar(context, bookSlug),

                Consumer<HadithChaptersProvider>(
                  builder: (context, provider, _) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomTextField(
                        label: 'Search Chapters',
                        onChanged: provider.updateSearchQuery,
                      ),
                    );
                  },
                ),

                Expanded(
                  child: Consumer<HadithChaptersProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return Center(child: _buildShimmerLoading());
                      }
                      if (provider.error != null) {
                        return Center(
                          child: Text(
                            "Error: ${provider.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (provider.chapters.isEmpty) {
                        return const Center(child: Text("No chapters found."));
                      }
                      return ListView.builder(
                        itemCount: provider.chapters.length,
                        itemBuilder: (context, index) {
                          final chapter = provider.chapters[index];
                          return ListTile(
                            title: Text(chapter.chapterEnglish),
                            subtitle: Text(chapter.chapterArabic),
                            trailing: Text("Chapter ${chapter.chapterNumber}"),
                            onTap: () {
                              print(
                                "Passing chapterNumber: ${chapter.chapterNumber}",
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HadithView(
                                    bookSlug: bookSlug,
                                    chapterId:
                                        chapter.chapterNumber,
                                  ),
                                ),
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
      ),
    );
  }
}

Widget _buildAppBar(BuildContext context, String bookSlug) {
  return Row(
    children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
      const SizedBox(width: 10),
      Text(
        bookSlug,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
    ],
  );
}

Widget _buildShimmerLoading() {
  return Column(
    children: List.generate(10, (index) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLoadingWidget(height: 20, width: 120),
                SizedBox(height: 5),
                ShimmerLoadingWidget(height: 20, width: 150),
              ],
            ),
            const ShimmerLoadingWidget(height: 20, width: 80),
          ],
        ),
      );
    }),
  );
}
