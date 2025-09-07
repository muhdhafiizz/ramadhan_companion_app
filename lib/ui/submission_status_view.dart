import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/model/sadaqah_model.dart';
import 'package:ramadhan_companion_app/provider/sadaqah_provider.dart';
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

                              return Container(
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.30),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Text(sadaqah.organization),
                                      const SizedBox(width: 5),
                                      StatusBadge(status: sadaqah.status),
                                    ],
                                  ),
                                  subtitle: GestureDetector(
                                    child: Text(
                                      sadaqah.url,
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  trailing: provider.isSuperAdmin
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (sadaqah.status == "pending")
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.check,
                                                  color: Colors.green,
                                                ),
                                                onPressed: () async {
                                                  final msg = await provider
                                                      .approveSadaqah(
                                                        sadaqah.id,
                                                      );

                                                  if (context.mounted) {
                                                    CustomPillSnackbar.show(
                                                      context,
                                                      message: msg,
                                                    );
                                                  }
                                                },
                                              ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () async {
                                                final msg = await provider
                                                    .removeSadaqah(sadaqah.id);

                                                if (context.mounted) {
                                                  CustomPillSnackbar.show(
                                                    context,
                                                    message: msg,
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        )
                                      : null,
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
