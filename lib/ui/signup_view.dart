import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/provider/signup_provider.dart';
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
                  _buildTextField(nameController, "Name"),
                  const SizedBox(height: 10),
                  _buildTextField(emailController, "Email"),
                  const SizedBox(height: 10),
                  _buildPasswordTextfield(passwordController, "Password"),
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

Widget _buildTextField(TextEditingController controller, String label) {
  return CustomTextField(controller: controller, label: label);
}

Widget _buildPasswordTextfield(TextEditingController controller, String label) {
  return CustomTextField(
    controller: controller,
    label: label,
    isPassword: true,
  );
}

Widget _buildSignupButton(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController emailController,
  TextEditingController passwordController,
) {
  final provider = Provider.of<SignupProvider>(context, listen: false);

  return CustomButton(
    text: "Sign Up",
    backgroundColor: Colors.black,
    textColor: Colors.white,
    onTap: () async {
      provider.showLoadingDialog(context);

      final success = await provider.signup(
        nameController.text,
        emailController.text,
        passwordController.text,
      );

      if (context.mounted) Navigator.pop(context);

      if (success && context.mounted) {
        print("✅ Successful sign up");
      } else {
        print("❌ Sign up failed: ${provider.error}");
      }
    },
  );
}
