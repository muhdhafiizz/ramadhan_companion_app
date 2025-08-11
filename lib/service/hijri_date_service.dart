import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/hijri_date_model.dart';

class HijriDateService {
  Future<HijriDateModel> getTodayHijriDate() async {
    final today = DateTime.now();
    final formattedDate =
        "${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}";

    final url = Uri.parse("https://api.aladhan.com/v1/gToH/$formattedDate");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return HijriDateModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to load Hijri date");
    }
  }
}
