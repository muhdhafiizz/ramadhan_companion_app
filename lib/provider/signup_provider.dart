import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupProvider extends ChangeNotifier {
  bool _obscurePassword = true;
  String? error;
  String _name = '';
  String _email = '';
  String _password = '';

  bool get obscurePassword => _obscurePassword;
  bool get isSignUpEnabled =>
      _email.isNotEmpty && _password.isNotEmpty && _name.isNotEmpty;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signup(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      await FirebaseFirestore.instance
          .collection('users_role')
          .doc(userCredential.user!.uid) // 👈 use UID instead of random id
          .set({
            'email': email.trim(),
            'role': 'user', // default role
          });

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
