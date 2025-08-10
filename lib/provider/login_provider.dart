import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ramadhan_companion_app/widgets/custom_loading_dialog.dart';

class LoginProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _user;
  bool _obscurePassword = true;
  String _email = '';
  String _password = '';

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  bool get isLoginEnabled => _email.isNotEmpty && _password.isNotEmpty;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (_) => const LoadingDialog(),
    );
  }

  void resetLoginState() {
    _email = '';
    _password = '';
    _error = null;
    _isLoading = false;
    _obscurePassword = true;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void updateEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    _password = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _user = {
        "uid": userCredential.user?.uid,
        "email": userCredential.user?.email,
        "displayName": userCredential.user?.displayName,
      };

      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Login failed: ${e.code} - ${e.message}");

      if (e.code == 'user-not-found') {
        _error = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        _error = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        _error = 'Invalid email address.';
      } else {
        _error = e.message ?? 'An unknown error occurred.';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      debugPrint("❌ Unexpected error: $e");
      debugPrint("Stack trace: $stackTrace");
      _error = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
