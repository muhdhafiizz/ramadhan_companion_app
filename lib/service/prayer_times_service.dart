import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ramadhan_companion_app/model/prayer_times_model.dart';

class PrayerTimesService {
  Future<PrayerTimesModel> getPrayerTimes(String city, String country) async {
    final url = Uri.parse(
      'https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=2',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PrayerTimesModel.fromJson(data);
    } else {
      throw Exception('Failed to load prayer times');
    }
  }
  
  Future<PrayerTimesModel> getPrayerTimesDate(String city, String country) async {
    final url = Uri.parse(
      'https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=2',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PrayerTimesModel.fromJson(data);
    } else {
      throw Exception('Failed to load prayer times');
    }
  }
}
