import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:ramadhan_companion_app/model/random_hadith_model.dart';
import '../secrets/api_keys.dart';

class RandomHadithService {
  static const String _baseUrl = 'https://hadithapi.com/api/hadiths/';

  Future<RandomHadithModel?> fetchRandomHadith({String? query}) async {
    try {
      final randomPage = Random().nextInt(50) + 1;

      final url = Uri.parse(
        '$_baseUrl?apiKey=${ApiKeys.hadithApiKey}&page=$randomPage${query != null ? '&query=$query' : ''}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['hadiths'] != null && data['hadiths']['data'] != null) {
          final hadiths = data['hadiths']['data'] as List;
          if (hadiths.isNotEmpty) {
            final randomIndex = Random().nextInt(hadiths.length);
            return RandomHadithModel.fromJson(hadiths[randomIndex]);
          }
        }
      } else {
        print('Failed to load hadith: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching random hadith: $e');
    }
    return null;
  }
}
