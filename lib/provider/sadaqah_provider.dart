import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ramadhan_companion_app/model/sadaqah_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SubmissionStatus { idle, submitting, success, failure }

class SadaqahProvider extends ChangeNotifier {
  SadaqahProvider() {
    loadSadaqahList();

    orgController.addListener(_onFormChanged);
    linkController.addListener(_onFormChanged);
    bankController.addListener(_onFormChanged);
    accountController.addListener(_onFormChanged);
  }
  String? _role;
  List<Sadaqah> _allSadaqah = [];
  List<Sadaqah> _filteredSadaqah = [];
  bool _isLoading = false;
  bool _hasShownReminder = false;
  bool _isFormValid = false;
  SubmissionStatus _submissionStatus = SubmissionStatus.idle;

  final orgController = TextEditingController();
  final linkController = TextEditingController();
  final bankController = TextEditingController();
  final accountController = TextEditingController();

  String? get role => _role;
  List<Sadaqah> get sadaqahList => _filteredSadaqah;
  bool get isLoading => _isLoading;
  bool get hasShownReminder => _hasShownReminder;
  bool get isFormValid => _isFormValid;
  bool get isSuperAdmin => _role == 'super_admin';
  SubmissionStatus get submissionStatus => _submissionStatus;

  Future<void> loadSadaqahList() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sadaqah_orgs')
          .where('status', isEqualTo: 'approved')
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

      await FirebaseFirestore.instance.collection('sadaqah_orgs').add(data);

      await loadSadaqahList();
      

      notifyListeners();
    } catch (e) {
      debugPrint("Error adding sadaqah: $e");
    }
  }

  void _onFormChanged() {
    final valid =
        orgController.text.trim().isNotEmpty &&
        linkController.text.trim().isNotEmpty &&
        bankController.text.trim().isNotEmpty &&
        accountController.text.trim().isNotEmpty;

    if (valid != _isFormValid) {
      _isFormValid = valid;
      notifyListeners();
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

  void resetRole() {
    _role = null;
    notifyListeners();
  }

  void resetForm() {
    orgController.clear();
    linkController.clear();
    bankController.clear();
    accountController.clear();
    _isFormValid = false;
    notifyListeners();
  }

  Future<void> fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users_role')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _role = doc.data()?['role'] ?? 'user';
      } else {
        _role = 'user';
      }
    } catch (e) {
      debugPrint("Error fetching user role: $e");
      _role = 'user';
    }

    notifyListeners();
  }

  Future<String> approveSadaqah(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('sadaqah_orgs')
          .doc(id)
          .update({'status': 'approved'});

      await loadSadaqahList();
      return "Approved";
    } catch (e) {
      debugPrint("Error approving: $e");
      return "Failed to approve";
    }
  }

  Future<String> removeSadaqah(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('sadaqah_orgs')
          .doc(id)
          .delete();

      await loadSadaqahList();
      return "Removed";
    } catch (e) {
      debugPrint("Error removing: $e");
      return "Failed to remove";
    }
  }
}
