import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/login_provider.dart';
import 'package:ramadhan_companion_app/provider/sadaqah_provider.dart';
import 'package:ramadhan_companion_app/ui/prayer_times_view.dart';
import 'package:ramadhan_companion_app/ui/signup_view.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';
import 'package:ramadhan_companion_app/widgets/custom_button.dart';
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
                  _appLogo(),
                  const SizedBox(height: 20),
                  _buildLottieView(provider),
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

Widget _appLogo() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        'assets/images/ummah_logo_transparent.png',
        height: 30,
        width: 30,
      ),
      SizedBox(width: 10),
      Text(
        'Ummah',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    ],
  );
}

Widget _buildLottieView(LoginProvider provider) {
  final pages = [
    {
      'lottie': 'assets/lottie/mosque_lottie.json',
      'title': 'Pray on time, every time',
      'subtitle': 'Discover nearby mosques and prayer times easily.',
    },
    {
      'lottie': 'assets/lottie/reading_quran_lottie.json',
      'title': 'Read & Reflect',
      'subtitle': 'Access the Quran and daily hadiths to boost your faith.',
    },
    {
      'lottie': 'assets/lottie/donate_lottie.json',
      'title': 'Give Sadaqah',
      'subtitle': 'Support local causes and earn lasting rewards.',
    },
  ];

  return Column(
    children: [
      Container(
        height: 350,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: PageView.builder(
          controller: provider.pageController,
          itemCount: pages.length,
          itemBuilder: (context, index) {
            final page = pages[index];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 250,
                  child: Lottie.asset(page['lottie']!, fit: BoxFit.contain),
                ),
                const SizedBox(height: 16),

                Text(
                  page['title']!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    page['subtitle']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      const SizedBox(height: 16),

      SmoothPageIndicator(
        controller: provider.pageController,
        count: pages.length,
        effect: ExpandingDotsEffect(
          dotColor: Colors.grey.shade300,
          activeDotColor: AppColors.violet.withOpacity(1),
          dotHeight: 8,
          dotWidth: 8,
        ),
      ),
    ],
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
