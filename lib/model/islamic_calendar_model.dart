class IslamicCalendarModel {
  final int month;
  final int day;
  final String name;

  IslamicCalendarModel({
    required this.month,
    required this.day,
    required this.name,
  });

  factory IslamicCalendarModel.fromJson(Map<String, dynamic> json) {
    return IslamicCalendarModel(
      month: json["month"] ?? 0,
      day: json["day"] ?? 0,
      name: json["name"] ?? "",
    );
  }
}

class IslamicCalendarResponse {
  final List<IslamicCalendarModel> days;

  IslamicCalendarResponse({required this.days});

  factory IslamicCalendarResponse.fromJson(Map<String, dynamic> json) {
    final data = json["data"] as List<dynamic>;
    return IslamicCalendarResponse(
      days: data.map((e) => IslamicCalendarModel.fromJson(e)).toList(),
    );
  }
}
