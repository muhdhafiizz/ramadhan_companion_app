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
import 'package:ramadhan_companion_app/widgets/custom_textfield.dart';
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
                                if (context.mounted) {
                                  CustomPillSnackbar.show(
                                    context,
                                    message: msg,
                                  );
                                }
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
                                if (context.mounted) {
                                  CustomPillSnackbar.show(
                                    context,
                                    message: msg,
                                  );
                                }
                              },
                            );
                          },
                        ),
                      if (sadaqah.submittedBy ==
                              FirebaseAuth.instance.currentUser?.uid &&
                          sadaqah.status == 'paid')
                        GestureDetector(
                          onTap: () async {
                            final service = ChipCollectService(
                              useSandbox: true,
                            );
                            try {
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
  String selectedStatus = 'All';

  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        children: [
          // 🔹 Filter Dropdown
          if (provider.isSuperAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: InputDecoration(
                  labelText: "Filter by Status",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'expired', child: Text('Expired')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                ],
                onChanged: (value) =>
                    setState(() => selectedStatus = value ?? 'All'),
              ),
            ),

          // 🔹 Programme List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: provider.isSuperAdmin
                  ? FirebaseFirestore.instance
                        .collection('masjidProgrammes')
                        .snapshots()
                  : FirebaseFirestore.instance
                        .collection('masjidProgrammes')
                        .where('submittedBy', isEqualTo: user?.uid)
                        .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;

                // // Apply search filter
                // final query = searchController.text.trim().toLowerCase();
                // if (query.isNotEmpty) {
                //   docs = docs.where((doc) {
                //     final data = doc.data() as Map<String, dynamic>;
                //     final masjidName = (data['masjidName'] ?? '')
                //         .toString()
                //         .toLowerCase();
                //     final location = (data['location'] ?? '')
                //         .toString()
                //         .toLowerCase();
                //     return masjidName.contains(query) ||
                //         location.contains(query);
                //   }).toList();
                // }

                // Apply status filter
                if (selectedStatus != 'All') {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['status'] == selectedStatus;
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const Center(
                    child: Text("No matching programmes found."),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final programmeId = docs[index].id;

                    return Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Poster image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: data['posterUrl'] != null
                                ? Image.memory(
                                    base64Decode(data['posterUrl']),
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 150,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image, size: 50),
                                  ),
                          ),
                          const SizedBox(height: 8),

                          // Title and status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  data['title'] ?? 'Untitled',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              StatusBadge(status: data['status']),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Masjid name + location
                          Text("Masjid: ${data['masjidName'] ?? ''}"),
                          Text("Location: ${data['location'] ?? 'N/A'}"),
                          Text("Date: ${data['dateTime'] ?? ''}"),

                          if (data['isOnline'] == true)
                            const StatusBadge(status: 'online')
                          else
                            const StatusBadge(status: 'offline'),

                          const SizedBox(height: 10),

                          // Approve / Reject Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (provider.isSuperAdmin &&
                                  data['status'] == "pending")
                                _buildGestureContainer(
                                  Colors.green,
                                  Colors.green,
                                  'Approve',
                                  Colors.green.withOpacity(0.1),
                                  onTap: () async {
                                    final programmeId = docs[index].id;
                                    final programmeData = data;

                                    try {
                                      // 🔹 Step 1: Mark as "pending to pay"
                                      await FirebaseFirestore.instance
                                          .collection('masjidProgrammes')
                                          .doc(programmeId)
                                          .update({
                                            'status': 'pending to pay',
                                            'paid': false,
                                          });

                                      // 🔹 Step 2: Fetch submitter info
                                      final submittedBy =
                                          programmeData['submittedBy'];
                                      final masjidName =
                                          programmeData['masjidName'] ??
                                          'the masjid';
                                      final submitterRole =
                                          programmeData['role'] ?? 'user';

                                      if (submittedBy != null) {
                                        // 🔹 Step 3: Send notification
                                        await FirebaseFirestore.instance
                                            .collection('notifications')
                                            .add({
                                              'title':
                                                  'Masjid Programme Payment Required',
                                              'message':
                                                  'Please proceed to pay for your approved masjid programme: $masjidName',
                                              'timestamp':
                                                  FieldValue.serverTimestamp(),
                                              'recipientRole': submitterRole,
                                              'recipientId': submittedBy,
                                              'read': false,
                                              'programmeId': programmeId,
                                            });
                                      }

                                      CustomPillSnackbar.show(
                                        context,
                                        message:
                                            "✅ Programme marked as 'pending to pay' and submitter notified.",
                                      );

                                      await context
                                          .read<MasjidProgrammeProvider>()
                                          .loadProgrammes();
                                    } catch (e) {
                                      debugPrint(
                                        "Error approving programme: $e",
                                      );
                                      CustomPillSnackbar.show(
                                        context,
                                        message:
                                            "❌ Failed to update programme.",
                                      );
                                    }
                                  },
                                ),
                              SizedBox(width: 5),

                              if (provider.isSuperAdmin &&
                                  data['status'] == "expired")
                                _buildGestureContainer(
                                  Colors.red,
                                  Colors.red,
                                  'Remove expired',
                                  Colors.red.withOpacity(0.1),
                                  onTap: () async {
                                    await FirebaseFirestore.instance
                                        .collection('masjidProgrammes')
                                        .doc(programmeId)
                                        .delete();

                                    await context
                                        .read<MasjidProgrammeProvider>()
                                        .loadProgrammes();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Expired programme deleted.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              SizedBox(width: 5),
                              if (provider.isSuperAdmin)
                                _buildGestureContainer(
                                  Colors.red,
                                  Colors.red,
                                  'Reject',
                                  Colors.red.withOpacity(0.1),
                                  onTap: () async {
                                    final reason =
                                        await _showRejectionReasonSheet(
                                          context,
                                          programmeId,
                                        );
                                    if (reason != null && reason.isNotEmpty) {
                                      await FirebaseFirestore.instance
                                          .collection('masjidProgrammes')
                                          .doc(programmeId)
                                          .update({
                                            'status': 'rejected',
                                            'rejectionReason': reason,
                                          });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Programme rejected: $reason',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              SizedBox(width: 5),
                              if (data['submittedBy'] ==
                                      FirebaseAuth.instance.currentUser?.uid &&
                                  data['paid'] == true)
                                GestureDetector(
                                  onTap: () async {
                                    final purchaseId = data['purchaseId'];
                                    if (purchaseId == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "No receipt available.",
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    final chipService = ChipCollectService(
                                      useSandbox: true,
                                    );
                                    try {
                                      final receipt = await chipService
                                          .getPurchase(purchaseId);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ReceiptView(receipt: receipt),
                                        ),
                                      );
                                    } catch (e) {
                                      debugPrint("Error fetching receipt: $e");
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Failed to load receipt: $e",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: AppColors.betterGray
                                        .withOpacity(0.3),
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildGestureContainer(
  Color borderColor,
  Color textColor,
  String text,
  Color backgroundColor, {
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
        color: backgroundColor,
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    ),
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

Future<String?> _showRejectionReasonSheet(
  BuildContext context,
  String programmeId,
) async {
  final reasonController = TextEditingController();
  final masjidProgrammeProvider = context.read<MasjidProgrammeProvider>();

  return await showModalBottomSheet<String>(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reject Submission",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Reason input
            CustomTextField(
              label: 'Reason for rejection',
              controller: reasonController,
              backgroundColor: AppColors.lightGray.withOpacity(1),
            ),

            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  onTap: () => Navigator.pop(context),
                  text: 'Cancel',
                ),
                const SizedBox(width: 10),
                CustomButton(
                  onTap: () {
                    final reason = reasonController.text.trim();
                    if (reason.isNotEmpty) {
                      Navigator.pop(context, reason);
                      masjidProgrammeProvider.removeProgramme(programmeId);
                      // Provider removal or update logic will be handled by caller
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a reason before rejecting.',
                          ),
                        ),
                      );
                    }
                  },
                  text: 'Reject',
                  backgroundColor: Colors.red.withOpacity(0.1),
                  textColor: Colors.red,
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
