import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramadhan_companion_app/provider/masjid_programme_provider.dart';
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
  final user = FirebaseAuth.instance.currentUser;

  final String? sadaqahId = notification['sadaqahId'];
  final String? programmeId = notification['programmeId'];
  final String? notificationDocId = notification['docId'];

  final bool isProgramme = programmeId != null;
  final bool isSadaqah = sadaqahId != null;

  if (!isProgramme && !isSadaqah) return const SizedBox();

  final currentNotif = notificationsProvider.notifications.firstWhere(
    (n) => n['docId'] == notificationDocId,
    orElse: () => notification,
  );

  final bool alreadyPaidLocal = (currentNotif['paid'] == true);

  final submittedBy = notification['recipientId'];
  final isSubmitter = submittedBy != null && submittedBy == user?.uid;

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
        if (!alreadyPaidLocal && isSubmitter) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _buildProceedToPayButton(
              context,
              notification,
              sadaqahId,
              programmeId,
              notificationDocId,
            ),
          ),
        ],
      ],
    );
  }

  if (!alreadyPaidLocal && isSubmitter) {
    return _buildProceedToPayButton(
      context,
      notification,
      sadaqahId,
      programmeId,
      notificationDocId,
    );
  }

  return const SizedBox();
}

Widget _buildProceedToPayButton(
  BuildContext context,
  Map<String, dynamic> notification,
  String? sadaqahId,
  String? programmeId,
  String? notificationDocId,
) {
  final user = FirebaseAuth.instance.currentUser;
  final sadaqahProvider = context.read<SadaqahProvider>();
  final masjidProgrammeProvider = context.read<MasjidProgrammeProvider>();
  final chipService = ChipCollectService(useSandbox: true);

  return CustomButton(
    text: "Proceed to Pay",
    backgroundColor: AppColors.violet.withOpacity(1),
    textColor: Colors.white,
    onTap: () async {
      final clientEmail = user?.email ?? "guest@example.com";
      final productName = notification['title'] ?? "Payment";

      final int price = sadaqahId != null
          ? sadaqahProvider.oneOffAmountInCents
          : masjidProgrammeProvider.oneOffAmountInCents;

      _showConfirmationSheet(
        context,
        clientEmail: clientEmail,
        productName: productName,
        price: price,
        chipService: chipService,
        sadaqahId: sadaqahId,
        programmeId: programmeId,
        notificationDocId: notificationDocId,
      );
    },
  );
}

Future<void> _showConfirmationSheet(
  BuildContext parentContext, {
  required String clientEmail,
  required String productName,
  required int price,
  required ChipCollectService chipService,
  String? sadaqahId,
  String? programmeId,
  String? notificationDocId,
}) async {
  await showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      String selectedMethod = "fpx";

      return FractionallySizedBox(
        heightFactor: 0.65,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const Text(
                        "Confirm Payment",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.betterGray.withOpacity(1),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLayout('Item', productName),
                            const Divider(),
                            _buildLayout('Email', clientEmail),
                            const Divider(),
                            _buildLayout(
                              'Amount',
                              'RM ${(price / 100).toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Select Payment Method",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Image.asset(
                              "assets/images/fpx_logo.png",
                              height: 24,
                            ),
                            const SizedBox(width: 10),
                            const Text("FPX"),
                          ],
                        ),
                        value: "fpx",
                        groupValue: selectedMethod,
                        onChanged: (value) {
                          setState(() => selectedMethod = value!);
                        },
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CustomButton(
                      text: "Confirm & Pay",
                      backgroundColor: AppColors.violet.withOpacity(1),
                      textColor: Colors.white,
                      onTap: () async {
                        Navigator.pop(context);

                        try {
                          final result = await chipService.createPurchase(
                            clientEmail: clientEmail,
                            productName: productName,
                            price: price,
                          );

                          final checkoutUrl = result['checkout_url'];
                          final purchaseId = result['id'];

                          if (sadaqahId != null) {
                            await FirebaseFirestore.instance
                                .collection('sadaqah_orgs')
                                .doc(sadaqahId)
                                .update({'purchaseId': purchaseId});
                          } else if (programmeId != null) {
                            await FirebaseFirestore.instance
                                .collection('masjidProgrammes')
                                .doc(programmeId)
                                .update({'purchaseId': purchaseId});
                          }

                          if (checkoutUrl != null && parentContext.mounted) {
                            Navigator.push(
                              parentContext,
                              MaterialPageRoute(
                                builder: (_) => WebViewPage(
                                  url: checkoutUrl,
                                  title: "Complete Payment",
                                  notificationDocId: notificationDocId,
                                  sadaqahId: sadaqahId,
                                  programmeId: programmeId,
                                ),
                              ),
                            );
                          } else {
                            CustomPillSnackbar.show(
                              parentContext,
                              message: "No checkout URL returned",
                            );
                          }
                        } catch (e) {
                          if (parentContext.mounted) {
                            CustomPillSnackbar.show(
                              parentContext,
                              message: "Error: $e",
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _buildLayout(String title, String subtitle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(height: 5),
      Text(subtitle),
    ],
  );
}
