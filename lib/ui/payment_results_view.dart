import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ramadhan_companion_app/ui/prayer_times_view.dart';
import 'package:ramadhan_companion_app/widgets/custom_button.dart';

class PaymentResultsView extends StatelessWidget {
  final bool isSuccess;

  const PaymentResultsView({super.key, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isSuccess
                    ? Lottie.asset(
                        'assets/lottie/payment_success_lottie.json',
                        height: 80,
                        width: 80,
                        repeat: false,
                      )
                    : Lottie.asset(
                        'assets/lottie/payment_failed_lottie.json',
                        height: 80,
                        width: 80,
                        repeat: false,
                      ),
                const SizedBox(height: 20),
                Text(
                  isSuccess ? "Payment Successful 🎉" : "Payment Failed ❌",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSuccess
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isSuccess
                      ? "You have helped people easier to sadaqah!"
                      : "Something went wrong. Please try again.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                CustomButton(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => PrayerTimesView()),
                    );
                  },
                  text: 'Back to Homepage',
                  backgroundColor: isSuccess ? Colors.green : Colors.red,
                  textColor: Colors.white,
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.pushReplacement(
                //       context,
                //       MaterialPageRoute(builder: (_) => PrayerTimesView()),
                //     );
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: isSuccess ? Colors.green : Colors.red,
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 24,
                //       vertical: 12,
                //     ),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //   ),
                //   child: const Text(
                //     "Back to Homepage",
                //     style: TextStyle(fontSize: 18, color: Colors.white),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
