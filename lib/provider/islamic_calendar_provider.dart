import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ramadhan_companion_app/model/islamic_calendar_model.dart';
import 'package:ramadhan_companion_app/service/islamic_calendar_service.dart';

class IslamicCalendarProvider extends ChangeNotifier {
  String? _error;
  HijriCalendar _focusedDate = HijriCalendar.now();
  IslamicCalendarModel? _islamicCalendarModel;

  String? get error => _error;
  HijriCalendar get focusedDate => _focusedDate;
  IslamicCalendarModel? get islamicCalendarModel => _islamicCalendarModel;

  List<IslamicCalendarModel> _specialDays = [];

  List<IslamicCalendarModel> get specialDays => _specialDays;

  final _service = IslamicCalendarService();

  Future<void> fetchSpecialDays() async {
    try {
      final result = await _service.getSpecialDays();

      _specialDays = result.days.where((day) {
        final lower = day.name.toLowerCase();
        return !(lower.startsWith("urs of") || lower.startsWith("birth of"));
      }).toList();

      notifyListeners();
    } catch (e) {
      print("Error fetching special days: $e");
    }
  }

  String get monthYearLabel =>
      "${_focusedDate.getLongMonthName()} ${_focusedDate.hYear}";

  int firstWeekdayOfMonth() {
    final first = HijriCalendar()
      ..hYear = _focusedDate.hYear
      ..hMonth = _focusedDate.hMonth
      ..hDay = 1;
    return first.weekDay();
  }

  void nextMonth() {
    final newMonth = _focusedDate.hMonth + 1;
    final newYear = newMonth > 12 ? _focusedDate.hYear + 1 : _focusedDate.hYear;
    final adjustedMonth = newMonth > 12 ? 1 : newMonth;

    _focusedDate = HijriCalendar()
      ..hYear = newYear
      ..hMonth = adjustedMonth
      ..hDay = 1
      ..gregorianToHijri(
        _focusedDate.hijriToGregorian(newYear, adjustedMonth, 1).year,
        _focusedDate.hijriToGregorian(newYear, adjustedMonth, 1).month,
        _focusedDate.hijriToGregorian(newYear, adjustedMonth, 1).day,
      );

    notifyListeners();
  }

  void prevMonth() {
    final newMonth = _focusedDate.hMonth - 1;
    final newYear = newMonth < 1 ? _focusedDate.hYear - 1 : _focusedDate.hYear;
    final adjustedMonth = newMonth < 1 ? 12 : newMonth;

    _focusedDate = HijriCalendar()
      ..hYear = newYear
      ..hMonth = adjustedMonth
      ..hDay = 1
      ..gregorianToHijri(
        _focusedDate.hijriToGregorian(newYear, adjustedMonth, 1).year,
        _focusedDate.hijriToGregorian(newYear, adjustedMonth, 1).month,
        _focusedDate.hijriToGregorian(newYear, adjustedMonth, 1).day,
      );

    notifyListeners();
  }

  List<HijriCalendar> getDaysInMonth() {
    final days = <HijriCalendar>[];

    final totalDays = _focusedDate.getDaysInMonth(
      _focusedDate.hYear,
      _focusedDate.hMonth,
    );

    for (int i = 1; i <= totalDays; i++) {
      final day = HijriCalendar()
        ..hYear = _focusedDate.hYear
        ..hMonth = _focusedDate.hMonth
        ..hDay = i
        ..gregorianToHijri(
          _focusedDate
              .hijriToGregorian(_focusedDate.hYear, _focusedDate.hMonth, i)
              .year,
          _focusedDate
              .hijriToGregorian(_focusedDate.hYear, _focusedDate.hMonth, i)
              .month,
          _focusedDate
              .hijriToGregorian(_focusedDate.hYear, _focusedDate.hMonth, i)
              .day,
        );

      days.add(day);
    }

    return days;
  }
}
