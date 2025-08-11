import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:ramadhan_companion_app/model/quran_daily_model.dart';

class QuranDailyService {
  final String baseUrl = "https://quranapi.pages.dev/api";

  Future<QuranDailyModel> getRandomVerse() async {
    final random = Random();
    final surahNo = random.nextInt(114) + 1;
    final firstAyahUrl = Uri.parse("$baseUrl/$surahNo/1.json");
    final firstAyahRes = await http.get(firstAyahUrl);

    if (firstAyahRes.statusCode != 200) {
      throw Exception("Failed to fetch first ayah (Surah $surahNo)");
    }

    final firstAyahJson = json.decode(firstAyahRes.body);
    final totalAyah = firstAyahJson['totalAyah'];

    if (totalAyah == null || totalAyah <= 0) {
      throw Exception("Invalid totalAyah from API");
    }

    final ayahNo = random.nextInt(totalAyah) + 1;
    final ayahUrl = Uri.parse("$baseUrl/$surahNo/$ayahNo.json");
    final ayahRes = await http.get(ayahUrl);

    if (ayahRes.statusCode != 200) {
      throw Exception("Failed to fetch ayah $ayahNo of surah $surahNo");
    }

    return QuranDailyModel.fromJson(json.decode(ayahRes.body));
  }
}
