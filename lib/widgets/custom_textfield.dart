import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/signup_provider.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final bool isPassword;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.isPassword = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final signupProvider = Provider.of<SignupProvider>(context);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: isPassword ? signupProvider.obscurePassword : false,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        floatingLabelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.black),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  signupProvider.obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: signupProvider.togglePasswordVisibility,
              )
            : null,
      ),
    );
  }
}
