import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/model/sadaqah_model.dart';
import 'package:ramadhan_companion_app/provider/masjid_programme_provider.dart';
import 'package:ramadhan_companion_app/provider/sadaqah_provider.dart';
import 'package:ramadhan_companion_app/service/chip_collect_service.dart';
import 'package:ramadhan_companion_app/ui/receipt_view.dart';
import 'package:ramadhan_companion_app/ui/webview_view.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';
import 'package:ramadhan_companion_app/widgets/custom_button.dart';
import 'package:ramadhan_companion_app/widgets/custom_pill_snackbar.dart';
import 'package:ramadhan_companion_app/widgets/custom_status_badge.dart';
// import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';

class MySubmissionsPage extends StatelessWidget {
  const MySubmissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SadaqahProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _buildAppBar(context),

                // ---- TabBar ----
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.betterGray.withOpacity(1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const TabBar(
                    indicator: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: "Sadaqah"),
                      Tab(text: "Programmes"),
                    ],
                  ),
                ),

                // ---- TabBarView ----
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildSadaqahList(provider),
                      _buildProgrammeList(provider),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildAppBar(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: Alignment.bottomLeft,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back),
        ),
      ),
      const SizedBox(height: 20),
      Text(
        "Progress",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    ],
  );
}

Widget _buildSadaqahList(SadaqahProvider provider) {
  final user = FirebaseAuth.instance.currentUser;

  return StreamBuilder(
    stream: provider.isSuperAdmin
        ? FirebaseFirestore.instance.collection('sadaqah_orgs').snapshots()
        : FirebaseFirestore.instance
              .collection('sadaqah_orgs')
              .where('submittedBy', isEqualTo: user?.uid)
              .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final docs = snapshot.data!.docs;
      if (docs.isEmpty) return const Center(child: Text("No submissions yet."));

      return ListView.builder(
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final data = docs[index].data();
          final sadaqah = Sadaqah.fromJson(data, docs[index].id);

          return GestureDetector(
            onTap: () => _showSubmissionDetail(
              context,
              sadaqah.organization,
              sadaqah.bankName,
              sadaqah.accountNumber,
            ),
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(sadaqah.organization),
                            const SizedBox(width: 5),
                            StatusBadge(status: sadaqah.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WebViewPage(
                                  url: sadaqah.url,
                                  title: sadaqah.organization,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            sadaqah.url,
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (provider.isSuperAdmin && sadaqah.status == "pending")
                        _buildButton(
                          Icons.check,
                          Colors.green.withOpacity(0.1),
                          Colors.green,
                          () {
                            showConfirmationModalBottomSheet(
                              context,
                              title:
                                  "Are you sure you want to approve this submission?",
                              confirmText: "Approve",
                              onConfirm: () async {
                                final msg = await provider.approveSadaqah(
                                  sadaqah.id,
                                );
                                if (context.mounted)
                                  CustomPillSnackbar.show(
                                    context,
                                    message: msg,
                                  );
                              },
                            );
                          },
                        ),
                      if (provider.isSuperAdmin)
                        _buildButton(
                          Icons.close,
                          Colors.red.withOpacity(0.1),
                          Colors.red,
                          () {
                            showConfirmationModalBottomSheet(
                              context,
                              title:
                                  "Are you sure you want to remove this submission?",
                              confirmText: "Remove",
                              onConfirm: () async {
                                final msg = await provider.removeSadaqah(
                                  sadaqah.id,
                                );
                                if (context.mounted)
                                  CustomPillSnackbar.show(
                                    context,
                                    message: msg,
                                  );
                              },
                            );
                          },
                        ),
                      if (sadaqah.submittedBy ==
                          FirebaseAuth.instance.currentUser?.uid)
                        GestureDetector(
                          onTap: () async {
                            final service = ChipCollectService(
                              useSandbox: true,
                            );
                            try {
                              // Replace with actual purchase ID you stored in Firestore when creating purchase
                              final receipt = await service.getPurchase(
                                sadaqah.purchaseId ?? "null",
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ReceiptView(receipt: receipt),
                                ),
                              );
                            } catch (e) {
                              print("Error fetching receipt: $e");
                              // Show snackbar if needed
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: AppColors.betterGray.withOpacity(
                              0.3,
                            ),
                            child: Image.asset(
                              'assets/icon/receipt_outlined_icon.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildProgrammeList(SadaqahProvider provider) {
  final user = FirebaseAuth.instance.currentUser;

  return StreamBuilder(
    stream: provider.isSuperAdmin
        ? FirebaseFirestore.instance.collection('masjidProgrammes').snapshots()
        : FirebaseFirestore.instance
              .collection('masjidProgrammes')
              .where('submittedBy', isEqualTo: user?.uid)
              .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final docs = snapshot.data!.docs;
      if (docs.isEmpty) {
        return const Center(child: Text("No programme submissions yet."));
      }

      return ListView.builder(
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final data = docs[index].data();
          final programmeId = docs[index].id;

          // final programmeDate = DateTime.tryParse(data['dateTime'] ?? '');
          // if (programmeDate != null && programmeDate.isBefore(DateTime.now())) {
          //   // 🚮 Delete expired programme
          //   FirebaseFirestore.instance
          //       .collection('masjidProgrammes')
          //       .doc(programmeId)
          //       .delete();

          //   return const SizedBox();
          // }

          return Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: data['posterUrl'] != null
                      ? Image.memory(
                          base64Decode(data['posterUrl']),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 50),
                        ),
                ),
                SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- LEFT SECTION (Details) ----
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(data['title'] ?? 'Untitled'),
                              const SizedBox(width: 5),
                              StatusBadge(status: data['status']),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text("Mosque: ${data['masjidName'] ?? ''}"),
                          Text("Date: ${data['dateTime'] ?? ''}"),
                          if (data['isOnline'] == true)
                            StatusBadge(status: 'online')
                          else
                            StatusBadge(status: 'offline'),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ---- RIGHT SECTION (Buttons) ----
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (provider.isSuperAdmin &&
                            data['status'] == "pending")
                          _buildButton(
                            Icons.check,
                            Colors.green.withOpacity(0.1),
                            Colors.green,
                            () async {
                              await FirebaseFirestore.instance
                                  .collection('masjidProgrammes')
                                  .doc(programmeId)
                                  .update({'status': 'approved'});
                              await context
                                  .read<MasjidProgrammeProvider>()
                                  .loadProgrammes();
                            },
                          ),
                        if (provider.isSuperAdmin)
                          _buildButton(
                            Icons.close,
                            Colors.red.withOpacity(0.1),
                            Colors.red,
                            () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                builder: (context) {
                                  final TextEditingController reasonController =
                                      TextEditingController();

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(
                                        context,
                                      ).viewInsets.bottom,
                                      left: 16,
                                      right: 16,
                                      top: 20,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Reject Programme",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          "Please provide a reason for rejecting this programme:",
                                          style: TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: reasonController,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            hintText:
                                                "Enter rejection reason...",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              onPressed: () async {
                                                final reason = reasonController
                                                    .text
                                                    .trim();

                                                if (reason.isEmpty) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Please provide a rejection reason.",
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                Navigator.pop(
                                                  context,
                                                ); 

                                                final programmeProvider = context
                                                    .read<
                                                      MasjidProgrammeProvider
                                                    >();

                                                final msg = await programmeProvider
                                                    .removeProgramme(
                                                      programmeId,
                                                      reason:
                                                          reason, 
                                                    );

                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(msg),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text("Reject"),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildButton(
  IconData icon,
  Color color,
  Color borderColor,
  VoidCallback onTap,
) {
  return CustomButton(
    onTap: onTap,
    borderColor: borderColor,
    iconData: icon,
    backgroundColor: color,
    textColor: borderColor,
  );
}

void showConfirmationModalBottomSheet(
  BuildContext context, {
  required String title,
  required String confirmText,
  required VoidCallback onConfirm,
}) {
  if (Platform.isIOS) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text(title),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            isDestructiveAction: true,
            child: Text(confirmText),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text(
                    confirmText,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showSubmissionDetail(
  BuildContext context,
  String title,
  String bankName,
  String accountNumber,
) {
  showModalBottomSheet(
    context: context,
    builder: (_) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Organization Name'),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text('Bank Name'),
          Text(
            bankName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text('Account Number'),

          GestureDetector(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: accountNumber));

              Navigator.pop(context);

              CustomPillSnackbar.show(
                context,
                message: "✅ Account number copied",
              );
            },
            child: Text(
              accountNumber,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

// Future<String?> _showRejectionReasonSheet(BuildContext context) async {
//   final reasonController = TextEditingController();

//   return await showModalBottomSheet<String>(
//     backgroundColor: Colors.white,
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (context) {
//       return Padding(
//         padding: EdgeInsets.only(
//           left: 16,
//           right: 16,
//           top: 16,
//           bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Reject Submission",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             const SizedBox(height: 20),

//             // Reason input
//             CustomTextField(
//               label: 'Reason for rejection',
//               controller: reasonController,
//               backgroundColor: AppColors.lightGray.withOpacity(1),
//             ),

//             const SizedBox(height: 20),

//             // Buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 CustomButton(
//                   onTap: () => Navigator.pop(context),
//                   text: 'Cancel',
//                 ),
//                 CustomButton(
//                   onTap: () =>
//                       Navigator.pop(context, reasonController.text.trim()),
//                   text: 'Reject',
//                   backgroundColor: Colors.red.withOpacity(0.1),
//                   textColor: Colors.red,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
