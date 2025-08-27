import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/hijri_date_model.dart';

class HijriDateService {
  Future<HijriDateModel> getHijriDateByGregorian(DateTime date) async {
    final formattedDate =
        "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";

    final url = Uri.parse("https://api.aladhan.com/v1/gToH/$formattedDate");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return HijriDateModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to load Hijri date");
    }
  }

  Future<HijriDateModel> getTodayHijriDate() async {
    return getHijriDateByGregorian(DateTime.now());
  }
}
