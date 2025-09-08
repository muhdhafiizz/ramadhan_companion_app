import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;

  StreamSubscription? _subscription;

  void startListening(String role, String userId) {
    _subscription?.cancel();

    _subscription = FirebaseFirestore.instance
        .collection('notifications')
        .where(
          Filter.or(
            Filter('recipientRole', isEqualTo: role),
            Filter('recipientId', isEqualTo: userId),
          ),
        )
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _notifications = snapshot.docs.map((doc) {
              final data = doc.data();
              data['docId'] = doc.id;
              return data;
            }).toList();
            notifyListeners();
          },
          onError: (e) {
            debugPrint("Error loading notifications: $e");
          },
        );
  }

  void markNotificationPaidLocally(String docId) {
    final idx = _notifications.indexWhere((n) => n['docId'] == docId);
    if (idx != -1) {
      _notifications[idx]['paid'] = true;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String docId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .update({'read': true});
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
