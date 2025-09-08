import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/model/sadaqah_model.dart';
import 'package:ramadhan_companion_app/provider/sadaqah_provider.dart';
import 'package:ramadhan_companion_app/ui/webview_view.dart';
import 'package:ramadhan_companion_app/widgets/app_colors.dart';
import 'package:ramadhan_companion_app/widgets/custom_pill_snackbar.dart';
import 'package:ramadhan_companion_app/widgets/custom_status_badge.dart';

class MySubmissionsPage extends StatelessWidget {
  const MySubmissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final provider = context.watch<SadaqahProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: provider.role == null
                    ? const Center(child: CircularProgressIndicator())
                    : StreamBuilder(
                        stream: provider.isSuperAdmin
                            ? FirebaseFirestore.instance
                                  .collection('sadaqah_orgs')
                                  .snapshots()
                            : FirebaseFirestore.instance
                                  .collection('sadaqah_orgs')
                                  .where('submittedBy', isEqualTo: user?.uid)
                                  .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final docs = snapshot.data!.docs;

                          if (docs.isEmpty) {
                            return const Center(
                              child: Text("No submissions yet."),
                            );
                          }

                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final data = docs[index].data();
                              final sadaqah = Sadaqah.fromJson(
                                data,
                                docs[index].id,
                              );

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Left: Main info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(sadaqah.organization),
                                                const SizedBox(width: 5),
                                                StatusBadge(
                                                  status: sadaqah.status,
                                                ),
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
                                                      title:
                                                          sadaqah.organization,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                sadaqah.url,
                                                style: const TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          if (provider.isSuperAdmin &&
                                              sadaqah.status == "pending")
                                            _buildButton(
                                              "Approve",
                                              Colors.green,
                                              () {
                                                showConfirmationModalBottomSheet(
                                                  context,
                                                  title:
                                                      "Are you sure you want to approve this submission?",
                                                  confirmText: "Approve",
                                                  onConfirm: () async {
                                                    final msg = await provider
                                                        .approveSadaqah(
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
                                            _buildButton("Remove", Colors.red, () {
                                              showConfirmationModalBottomSheet(
                                                context,
                                                title:
                                                    "Are you sure you want to remove this submission?",
                                                confirmText: "Remove",
                                                onConfirm: () async {
                                                  final msg = await provider
                                                      .removeSadaqah(
                                                        sadaqah.id,
                                                      );
                                                  if (context.mounted)
                                                    CustomPillSnackbar.show(
                                                      context,
                                                      message: msg,
                                                    );
                                                },
                                              );
                                            }),
                                          if (sadaqah.submittedBy ==
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser
                                                  ?.uid)
                                            GestureDetector(
                                              onTap: (){
                                                print('receipt view');
                                              },
                                              child: CircleAvatar(
                                                backgroundColor: AppColors.betterGray.withOpacity(0.3),
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
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildAppBar(BuildContext context) {
  return Row(
    children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Icon(Icons.arrow_back),
      ),
      SizedBox(width: 10),
      Text(
        "Progress",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    ],
  );
}

Widget _buildButton(String text, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    ),
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
