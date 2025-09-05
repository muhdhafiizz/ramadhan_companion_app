import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/signup_provider.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final bool isPassword;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final Color? backgroundColor;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.isPassword = false,
    this.onChanged,
    this.keyboardType,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final signupProvider = Provider.of<SignupProvider>(context);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: isPassword ? signupProvider.obscurePassword : false,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        filled: true,
        fillColor: backgroundColor ?? Colors.white,
        hintText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        floatingLabelStyle: const TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.transparent),
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
