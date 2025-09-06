import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ramadhan_companion_app/model/sadaqah_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SubmissionStatus { idle, submitting, success, failure }

class SadaqahProvider extends ChangeNotifier {
  SadaqahProvider() {
    loadSadaqahList();
  }

  List<Sadaqah> _allSadaqah = [];
  List<Sadaqah> _filteredSadaqah = [];
  bool _isLoading = false;
  bool _hasShownReminder = false;
  SubmissionStatus _submissionStatus = SubmissionStatus.idle;

  final orgController = TextEditingController();
  final linkController = TextEditingController();
  final bankController = TextEditingController();
  final accountController = TextEditingController();

  List<Sadaqah> get sadaqahList => _filteredSadaqah;
  bool get isLoading => _isLoading;
  bool get hasShownReminder => _hasShownReminder;
  SubmissionStatus get submissionStatus => _submissionStatus;

  Future<void> loadSadaqahList() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sadaqah_orgs')
          .get();

      _allSadaqah = snapshot.docs
          .map((doc) => Sadaqah.fromJson(doc.data(), doc.id))
          .toList();

      _filteredSadaqah = _allSadaqah;
    } catch (e) {
      debugPrint("Error loading sadaqah: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSadaqah(Sadaqah sadaqah) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      final data = sadaqah.toJson();
      data['submittedBy'] = user?.uid ?? "unknown";
      data['status'] = "pending";

      final docRef = await FirebaseFirestore.instance
          .collection('sadaqah_orgs')
          .add(data);

      _allSadaqah.add(Sadaqah.fromJson(data, docRef.id));
      _filteredSadaqah = _allSadaqah;
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding sadaqah: $e");
    }
  }

  void resetSubmissionStatus() {
    _submissionStatus = SubmissionStatus.idle;
    notifyListeners();
  }

  void search(String query) {
    if (query.isEmpty) {
      _filteredSadaqah = _allSadaqah;
    } else {
      _filteredSadaqah = _allSadaqah.where((s) {
        return s.organization.toLowerCase().contains(query.toLowerCase()) ||
            s.bankName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void markReminderShown() {
    _hasShownReminder = true;
    notifyListeners();
  }

  void dismissReminder() {
    _hasShownReminder = false;
    notifyListeners();
  }
}
