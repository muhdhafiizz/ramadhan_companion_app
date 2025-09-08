import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramadhan_companion_app/provider/notifications_provider.dart';
import 'package:ramadhan_companion_app/provider/sadaqah_provider.dart';
import 'package:ramadhan_companion_app/ui/submission_status_view.dart';
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

  if (sadaqahProvider.role == 'super_admin') {
    return CustomButton(
      text: "View",
      backgroundColor: AppColors.violet.withOpacity(1),
      textColor: Colors.white,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MySubmissionsPage()),
        );
      },
    );
  }

  final currentNotif = notificationsProvider.notifications.firstWhere(
    (n) => n['docId'] == notificationDocId,
    orElse: () => notification,
  );

  final bool alreadyPaidLocal = (currentNotif['paid'] == true);

  if (alreadyPaidLocal) {
    return const SizedBox();
  }

  return CustomButton(
    text: "Proceed to Pay",
    backgroundColor: AppColors.violet.withOpacity(1),
    textColor: Colors.white,
    onTap: () async {
      final msg = await sadaqahProvider.paySadaqah(sadaqahId);

      if (context.mounted) {
        CustomPillSnackbar.show(context, message: msg);
      }

      // If the payment function returned success, update local provider (so UI hides the button)
      final success = msg.toLowerCase().contains('success'); // robust check
      if (success) {
        // 1) Update local copy so UI updates immediately
        if (notificationDocId != null) {
          notificationsProvider.markNotificationPaidLocally(notificationDocId);
        }

        // 2) (Optional but recommended) update the notification doc in Firestore
        // so that other clients (or next provider stream) see it too.
        if (notificationDocId != null) {
          try {
            await FirebaseFirestore.instance
                .collection('notifications')
                .doc(notificationDocId)
                .update({'paid': true});
          } catch (e) {
            debugPrint('Failed to update notification doc paid flag: $e');
          }
        }
      } else {
        // Payment failed: do nothing — button remains
      }
    },
  );
}
