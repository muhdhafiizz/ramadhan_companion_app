class HijriDateModel {
  final String hijriDate;
  final String hijriDay;
  final String hijriMonth;
  final String hijriYear;

  final String gregorianDate;
  final String gregorianDay;
  final String gregorianDayDate;
  final String gregorianMonth;
  final String gregorianYear;

  HijriDateModel({
    required this.hijriDate,
    required this.hijriDay,
    required this.hijriMonth,
    required this.hijriYear,
    required this.gregorianDate,
    required this.gregorianDayDate,
    required this.gregorianDay,
    required this.gregorianMonth,
    required this.gregorianYear,
  });

  factory HijriDateModel.fromJson(Map<String, dynamic> json) {
    final hijri = json['data']['hijri'];
    final gregorian = json['data']['gregorian'];

    return HijriDateModel(
      hijriDate: hijri['date'],
      hijriDay: hijri['day'],
      hijriMonth: hijri['month']['en'],
      hijriYear: hijri['year'],
      gregorianDate: gregorian['date'],
      gregorianDayDate: gregorian['day'],
      gregorianDay: gregorian['weekday']['en'],
      gregorianMonth: gregorian['month']['en'],
      gregorianYear: gregorian['year'],
    );
  }
}
