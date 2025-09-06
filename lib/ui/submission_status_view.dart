import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ramadhan_companion_app/model/sadaqah_model.dart';
import '../provider/sadaqah_provider.dart';

class MySubmissionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text("My Submissions")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('sadaqah_orgs')
            .where('submittedBy', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text("No submissions yet."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final sadaqah = Sadaqah.fromJson(data, docs[index].id);

              return ListTile(
                title: Text(sadaqah.organization),
                subtitle: Text("Status: ${sadaqah.status}"),
              );
            },
          );
        },
      ),
    );
  }
}
