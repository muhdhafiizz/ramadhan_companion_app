import 'package:flutter/cupertino.dart';
import 'package:ramadhan_companion_app/model/hijri_date_model.dart';

class DateProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  HijriDateModel? _hijriDateModel;

  DateTime get selectedDate => _selectedDate;
  HijriDateModel? get hijriDateModel => _hijriDateModel;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void nextDay() {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    notifyListeners();
  }

  void previousDay() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    notifyListeners();
  }
}
