import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ramadhan_companion_app/model/islamic_calendar_model.dart';

class IslamicCalendarService {
  Future<IslamicCalendarResponse> getSpecialDays() async {
    final url = Uri.parse('https://api.aladhan.com/v1/specialDays');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      return IslamicCalendarResponse.fromJson(data);
    } else {
      throw Exception('Failed to load special days');
    }
  }
}
