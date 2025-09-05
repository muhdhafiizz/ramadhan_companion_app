import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadhan_companion_app/provider/quran_provider.dart';
import 'package:ramadhan_companion_app/ui/quran_detail_view.dart';
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';

class QuranView extends StatelessWidget {
  const QuranView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildAppBar(context),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextField(
                  
                  label: "Search Surah",
                  onChanged: provider.updateQuery,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      controller: provider.scrollController,
                      itemCount: provider.filteredSurahs.length,
                      itemBuilder: (context, i) {
                        final index = provider.filteredSurahs[i];
                        return ListTile(
                          title: Text(
                            "$index. ${quran.getSurahName(index)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Verses: ${quran.getVerseCount(index)}",
                          ),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SurahDetailView(surahNumber: index),
                              ),
                            );
                          },
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
                              shape: CircleBorder(),
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
                              shape: CircleBorder(),
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
    );
  }
}

Widget _buildAppBar(BuildContext context) {
  return Row(
    children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
      const SizedBox(width: 10),
      const Text(
        "Surah",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    ],
  );
}
