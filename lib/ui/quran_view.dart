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
    final provider = Provider.of<QuranProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildAppBar(context),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextField(
                  label: "Search Surah",
                  onChanged: (val) => provider.updateQuery(val),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.filteredSurahs.length,
                  itemBuilder: (context, i) {
                    final index = provider.filteredSurahs[i];
                    return ListTile(
                      title: Text(
                        "${index}. ${quran.getSurahName(index)}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Verses: ${quran.getVerseCount(index)}"),
                      trailing: const Icon(Icons.arrow_forward),
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
        child: Icon(Icons.arrow_back),
      ),
      SizedBox(width: 10),
      Text(
        "Surah",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    ],
  );
}
