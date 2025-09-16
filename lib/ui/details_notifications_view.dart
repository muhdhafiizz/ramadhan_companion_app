import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramadhan_companion_app/provider/notifications_provider.dart';
import 'package:ramadhan_companion_app/provider/sadaqah_provider.dart';
import 'package:ramadhan_companion_app/service/chip_collect_service.dart';
import 'package:ramadhan_companion_app/ui/submission_status_view.dart';
import 'package:ramadhan_companion_app/ui/webview_view.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';
import 'package:ramadhan_companion_app/widgets/custom_button.dart';
import 'package:ramadhan_companion_app/widgets/custom_pill_snackbar.dart';

class DetailsNotificationsView extends StatelessWidget {
  final Map<String, dynamic> notification;

  const DetailsNotificationsView({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NotificationsProvider>();

    if (!(notification['read'] ?? false) && notification['docId'] != null) {
      provider.markAsRead(notification['docId']);
      notification['read'] = true;
    }

    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 30,
          top: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, -1),
              blurRadius: 6,
            ),
          ],
        ),
        child: _buildViewButton(context, notification),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 20),
              Text(
                notification['timestamp'] != null
                    ? (notification['timestamp'] as Timestamp)
                          .toDate()
                          .toLocal()
                          .toString()
                    : 'No date',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Text(
                notification['title'] ?? 'No title',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                notification['message'] ?? 'No message',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildViewButton(
  BuildContext context,
  Map<String, dynamic> notification,
) {
  final notificationsProvider = context.watch<NotificationsProvider>();
  final sadaqahProvider = context.read<SadaqahProvider>();
  final String? sadaqahId = notification['sadaqahId'];
  final String? notificationDocId = notification['docId'];

  if (sadaqahId == null) return const SizedBox();

  final currentNotif = notificationsProvider.notifications.firstWhere(
    (n) => n['docId'] == notificationDocId,
    orElse: () => notification,
  );

  final bool alreadyPaidLocal = (currentNotif['paid'] == true);

  if (sadaqahProvider.role == 'super_admin') {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: "View",
            backgroundColor: Colors.grey.shade200,
            textColor: Colors.black,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MySubmissionsPage()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        if (!alreadyPaidLocal)
          Expanded(
            child: CustomButton(
              text: "Proceed to Pay",
              backgroundColor: AppColors.violet.withOpacity(1),
              textColor: Colors.white,
              onTap: () async {
                final msg = await sadaqahProvider.paySadaqah(sadaqahId);

                if (context.mounted) {
                  CustomPillSnackbar.show(context, message: msg);
                }

                final success = msg.toLowerCase().contains('success');
                if (success && notificationDocId != null) {
                  notificationsProvider.markNotificationPaidLocally(
                    notificationDocId,
                  );
                  try {
                    await FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(notificationDocId)
                        .update({'paid': true});
                  } catch (e) {
                    debugPrint(
                      'Failed to update notification doc paid flag: $e',
                    );
                  }
                }
              },
            ),
          ),
      ],
    );
  }

  // 🟣 For normal users → only "Proceed to Pay"
  if (alreadyPaidLocal) return const SizedBox();

  return CustomButton(
    text: "Proceed to Pay",
    backgroundColor: AppColors.violet.withOpacity(1),
    textColor: Colors.white,
    onTap: () async {
      try {
        final chipService = ChipCollectService();
        final sadaqahProvider = context.read<SadaqahProvider>();
        final user = FirebaseAuth.instance.currentUser;

        final clientEmail = user?.email ?? "guest@example.com";
        final productName = notification['title'] ?? "Sadaqah Donation";
        final price = sadaqahProvider.oneOffAmountInCents;

        final result = await chipService.createPurchase(
          clientEmail: clientEmail,
          productName: productName,
          price: price,
        );
        

        final checkoutUrl = result['data']?['checkout_url'];

        if (checkoutUrl != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  WebViewPage(url: checkoutUrl, title: "Complete Payment"),
            ),
          );
        } else {
          CustomPillSnackbar.show(context, message: "No checkout URL returned");
        }
      } catch (e) {
        if (context.mounted) {
          CustomPillSnackbar.show(context, message: "Error: $e");
        }
      }
    },

    // onTap: () async {
    //   final msg = await sadaqahProvider.paySadaqah(sadaqahId);

    //   if (context.mounted) {
    //     CustomPillSnackbar.show(context, message: msg);
    //   }

    //   final success = msg.toLowerCase().contains('success');
    //   if (success && notificationDocId != null) {
    //     notificationsProvider.markNotificationPaidLocally(notificationDocId);
    //     try {
    //       await FirebaseFirestore.instance
    //           .collection('notifications')
    //           .doc(notificationDocId)
    //           .update({'paid': true});
    //     } catch (e) {
    //       debugPrint('Failed to update notification doc paid flag: $e');
    //     }
    //   }
    // },
  );
}
