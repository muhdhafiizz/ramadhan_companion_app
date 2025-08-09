import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ramadhan_companion_app/widgets/custom_loading_dialog.dart';

class SignupProvider extends ChangeNotifier {
  bool _obscurePassword = true;
  String? error;

  bool get obscurePassword => _obscurePassword;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signup(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();
      error = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {

      if (e.code == 'weak-password') {
        error = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        error = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        error = 'The email address is invalid.';
      } else {
        error = e.message ?? 'An unknown error occurred.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      error = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (_) => const LoadingDialog(),
    );
  }
}
