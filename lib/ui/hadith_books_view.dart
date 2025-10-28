import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/hadith_books_provider.dart';
import 'package:ramadhan_companion_app/ui/hadith_chapters_view.dart';
import 'package:ramadhan_companion_app/widgets/shimmer_loading.dart';

class HadithBooksView extends StatelessWidget {
  const HadithBooksView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HadithBooksProvider()..loadBooks(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                SizedBox(height: 10),
                Expanded(
                  child: Consumer<HadithBooksProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return _buildShimmerLoading();
                      }

                      if (provider.error != null) {
                        return Center(
                          child: Text(
                            "Error: ${provider.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (provider.books.isEmpty) {
                        return const Center(
                          child: Text("No hadith books found."),
                        );
                      }

                      return ListView.builder(
                        itemCount: provider.books.length,
                        itemBuilder: (context, index) {
                          final book = provider.books[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            child: ListTile(
                              title: Text(
                                book.bookName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "${book.writerName} • ${book.writerDeath}",
                              ),
                              trailing: Text(
                                "${book.hadithsCount} hadiths",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HadithChaptersView(
                                      bookSlug: book.bookSlug,
                                    ),
                                  ),
                                );
                              },
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
      ),
    );
  }
}

Widget _buildAppBar(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back),
        ),
        const SizedBox(height: 20),
        const Text(
          'Hadiths',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ],
    ),
  );
}

Widget _buildShimmerLoading() {
  return Column(
    children: List.generate(4, (index) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
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
