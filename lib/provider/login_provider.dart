import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isForgotPasswordLoading = false;
  String? _error;
  Map<String, dynamic>? _user;
  bool _obscurePassword = true;
  String _email = '';
  String _password = '';

  bool get isLoading => _isLoading;
  bool get isForgotPasswordLoading => _isForgotPasswordLoading;
  bool get obscurePassword => _obscurePassword;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  bool get isLoginEnabled => _email.isNotEmpty && _password.isNotEmpty;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final pageController = PageController();

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

  Future<void> sendPasswordReset(BuildContext context, String email) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first.')),
      );
      return;
    }

    try {
      _isForgotPasswordLoading = true;
      notifyListeners();

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

      _isForgotPasswordLoading = false;
      notifyListeners();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset link sent to $email'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      _isForgotPasswordLoading = false;
      notifyListeners();

      String message = 'Something went wrong';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      _isForgotPasswordLoading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }
}
