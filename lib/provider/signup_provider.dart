import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupProvider extends ChangeNotifier {
  bool _obscurePassword = true;
  String? error;
  String _name = '';
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  bool get obscurePassword => _obscurePassword;
  bool get isSignUpEnabled =>
      _email.isNotEmpty && _password.isNotEmpty && _name.isNotEmpty;
  bool get isLoading => _isLoading;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signup(String name, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      await FirebaseFirestore.instance
          .collection('users_role')
          .doc(userCredential.user!.uid)
          .set({'email': email.trim(), 'role': 'user'});

      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      error = null;
      _isLoading = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();

      if (e.code == 'weak-password') {
        error = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        error = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        error = 'The email address is invalid.';
      } else {
        error = e.message ?? 'An unknown error occurred.';
      }

      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void updateName(String value) {
    _name = value;
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
}
