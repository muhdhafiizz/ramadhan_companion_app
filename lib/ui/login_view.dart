import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/login_provider.dart';
import 'package:ramadhan_companion_app/provider/sadaqah_provider.dart';
import 'package:ramadhan_companion_app/ui/prayer_times_view.dart';
import 'package:ramadhan_companion_app/ui/signup_view.dart';
import 'package:ramadhan_companion_app/widgets/custom_button.dart';
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSignUpButton(context),
            _buildLoginButton(context, emailController, passwordController),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Consumer<LoginProvider>(
            builder: (context, provider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  _buildLottieView(),
                  _buildLoginText(),
                  const SizedBox(height: 20),
                  _buildEmailTextfield(emailController, "Email", provider),
                  const SizedBox(height: 10),
                  _buildPasswordTextfield(
                    passwordController,
                    "Password",
                    provider,
                  ),
                  const SizedBox(height: 20),
                  if (provider.error != null)
                    Text(
                      provider.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

Widget _buildLottieView() {
  return Lottie.asset('assets/lottie/mosque_lottie.json');
}

Widget _buildLoginText() {
  return Text(
    "Login now for the best experience",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  );
}

Widget _buildEmailTextfield(
  TextEditingController controller,
  String label,
  LoginProvider provider,
) {
  return CustomTextField(
    controller: controller,
    label: label,
    onChanged: (value) {
      provider.updateEmail(value);
    },
  );
}

Widget _buildPasswordTextfield(
  TextEditingController controller,
  String label,
  LoginProvider provider,
) {
  return CustomTextField(
    controller: controller,
    label: label,
    onChanged: (value) {
      provider.updatePassword(value);
    },
    isPassword: true,
  );
}

Widget _buildLoginButton(
  BuildContext context,
  TextEditingController emailController,
  TextEditingController passwordController,
) {
  return Consumer<LoginProvider>(
    builder: (context, provider, _) {
      return CustomButton(
        text: provider.isLoading ? "" : "Log in", // 🔹 hide text when loading
        backgroundColor: provider.isLoginEnabled ? Colors.black : Colors.grey,
        textColor: Colors.white,
        onTap: provider.isLoginEnabled && !provider.isLoading
            ? () async {
                final success = await provider.login(
                  emailController.text,
                  passwordController.text,
                );

                if (!context.mounted) return;

                await context.read<SadaqahProvider>().fetchUserRole();

                if (success && context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PrayerTimesView()),
                  );
                }
              }
            : null,
        // 👇 use iconData slot for loader instead of icon
        iconData: provider.isLoading ? null : null,
      );
    },
  );
}

Widget _buildSignUpButton(BuildContext context) {
  return CustomButton(
    text: "Sign up",
    backgroundColor: Colors.white,
    textColor: Colors.black,
    borderColor: Colors.black,
    onTap: () async {
      Navigator.push(context, MaterialPageRoute(builder: (_) => SignupView()));
    },
  );
}
