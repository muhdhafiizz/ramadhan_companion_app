import 'package:flutter/material.dart';

class LocationInputProvider extends ChangeNotifier {
  String _city = '';
  String _country = '';

  String get city => _city;
  String get country => _country;

  bool get isButtonEnabled => _city.isNotEmpty && _country.isNotEmpty;

  void setCity(String value) {
    _city = value;
    notifyListeners();
  }

  void setCountry(String value) {
    _country = value;
    notifyListeners();
  }
}
