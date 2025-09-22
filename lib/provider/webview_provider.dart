import 'package:flutter/foundation.dart';

class PaymentWebViewProvider extends ChangeNotifier {
  String? _status;
  String? get status => _status;

  void setStatus(String newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}
