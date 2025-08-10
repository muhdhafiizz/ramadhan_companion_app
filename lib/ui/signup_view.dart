import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/signup_provider.dart';
import 'package:ramadhan_companion_app/widgets/custom_appbar.dart';
import 'package:ramadhan_companion_app/widgets/custom_button.dart';
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';

class SignupView extends StatelessWidget {
  SignupView({super.key});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: _buildSignupButton(
          context,
          nameController,
          emailController,
          passwordController,
        ),
      ),
      appBar: CustomAppbar(showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<SignupProvider>(
            builder: (context, provider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  _buildSignupText(),
                  const SizedBox(height: 20),
                  _buildNameTextField(nameController, "Name", provider),
                  const SizedBox(height: 10),
                  _buildEmailTextField(emailController, "Email", provider),
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
                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

Widget _buildSignupText() {
  return const Text(
    "Create your Account",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  );
}

Widget _buildNameTextField(
  TextEditingController controller,
  String label,
  SignupProvider provider,
) {
  return CustomTextField(
    controller: controller,
    label: label,
    onChanged: (value) {
      provider.updateName(value);
    },
  );
}

Widget _buildEmailTextField(
  TextEditingController controller,
  String label,
  SignupProvider provider,
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
  SignupProvider provider,
) {
  return CustomTextField(
    controller: controller,
    label: label,
    isPassword: true,
    onChanged: (value) {
      provider.updatePassword(value);
    },
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
        text: "Sign Up",
        backgroundColor: provider.isSignUpEnabled ? Colors.black : Colors.grey,
        textColor: Colors.white,
        onTap: provider.isSignUpEnabled
            ? () async {
                provider.showLoadingDialog(context);

                final success = await provider.signup(
                  nameController.text,
                  emailController.text,
                  passwordController.text,
                );

                if (context.mounted) Navigator.pop(context);

                if (success && context.mounted) {
                  print("Successful sign up");
                  Navigator.pop(context);
                } else {
                  print("Sign up failed: ${provider.error}");
                }
              }
            : null,
      );
    },
  );
}
