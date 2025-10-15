import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/signup_provider.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';
import 'package:ramadhan_companion_app/widgets/custom_button.dart';
import 'package:ramadhan_companion_app/widgets/custom_loading_dialog.dart';
import 'package:ramadhan_companion_app/widgets/custom_success_dialog.dart';
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';

class SignupView extends StatelessWidget {
  SignupView({super.key});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SignupProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/mosque_2_image.jpg',
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.darken,
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SafeArea(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent.withOpacity(0.1),
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSignupText(),
                  const Spacer(),
                  _buildContainer(
                    nameController,
                    emailController,
                    passwordController,
                    provider,
                    context,
                  ),
                ],
              ),
            ],
          );
        },
        // ),
      ),
    );
  }
}

Widget _buildContainer(
  TextEditingController nameController,
  TextEditingController emailController,
  TextEditingController passwordController,
  SignupProvider provider,
  BuildContext context,
) {
  return Container(
    height: 420,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.lightGray.withOpacity(1),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNameTextField(nameController, "Name", provider),
        const SizedBox(height: 10),
        _buildEmailTextField(emailController, "Email", provider),
        const SizedBox(height: 10),
        _buildPasswordTextfield(passwordController, "Password", provider),
        const SizedBox(height: 20),
        if (provider.error != null)
          Text(
            provider.error!,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        Spacer(),
        _buildSignupButton(
          context,
          nameController,
          emailController,
          passwordController,
        ),
      ],
    ),
  );
}

Widget _buildSignupText() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        const Text(
          "Welcome to Ummah",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 50,
            color: Colors.white,
          ),
        ),
        const Text(
          "Setup your account to be part of community.",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ],
    ),
  );
}

Widget _buildNameTextField(
  TextEditingController controller,
  String label,
  SignupProvider provider,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Name',
        style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.5)),
      ),
      SizedBox(height: 5),
      CustomTextField(
        controller: controller,
        label: label,
        onChanged: provider.updateName,
      ),
    ],
  );
}

Widget _buildEmailTextField(
  TextEditingController controller,
  String label,
  SignupProvider provider,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Email',
        style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.5)),
      ),
      SizedBox(height: 5),
      CustomTextField(
        controller: controller,
        label: label,
        onChanged: provider.updateEmail,
      ),
    ],
  );
}

Widget _buildPasswordTextfield(
  TextEditingController controller,
  String label,
  SignupProvider provider,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Password',
        style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.5)),
      ),
      SizedBox(height: 5),
      CustomTextField(
        controller: controller,
        label: label,
        isPassword: true,
        onChanged: provider.updatePassword,
      ),
    ],
  );
}

Widget _buildSignupButton(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController emailController,
  TextEditingController passwordController,
) {
  return Consumer<SignupProvider>(
    builder: (context, provider, _) {
      return CustomButton(
        text: provider.isLoading ? "" : "Sign Up",
        backgroundColor: provider.isSignUpEnabled ? Colors.black : Colors.grey,
        textColor: Colors.white,
        onTap: provider.isSignUpEnabled && !provider.isLoading
            ? () async {
                final success = await provider.signup(
                  nameController.text,
                  emailController.text,
                  passwordController.text,
                );

                if (!context.mounted) return;

                if (success) {
                  await showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => const CustomSuccessDialog(
                      message: "Signed up successfully!",
                    ),
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              }
            : null,
        iconData: provider.isLoading ? null : null,
      );
    },
  );
}

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.2),
    builder: (_) => const LoadingDialog(),
  );
}

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.2),
    builder: (_) => const LoadingDialog(),
  );
}
