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
  String? _email;
  String _filterCategory = "All";
  String _formCategory = "All";
  List<Sadaqah> _allSadaqah = [];
  List<Sadaqah> _filteredSadaqah = [];
  bool _isLoading = false;
  bool _hasShownReminder = false;
  bool _isFormValid = false;
  double oneOffAmount = 21.90;

  SubmissionStatus _submissionStatus = SubmissionStatus.idle;

  final orgController = TextEditingController();
  final linkController = TextEditingController();
  final bankController = TextEditingController();
  final accountController = TextEditingController();

  String? get role => _role;
  String? get email => _email;
  String get filterCategory => _filterCategory;
  String get formCategory => _formCategory;
  List<Sadaqah> get sadaqahList => _filteredSadaqah;
  // List<Sadaqah> get sadaqahList => _filteredSadaqah;
  bool get isLoading => _isLoading;
  bool get hasShownReminder => _hasShownReminder;
  bool get isFormValid => _isFormValid;
  bool get isSuperAdmin => _role == 'super_admin';
  int get oneOffAmountInCents => (oneOffAmount * 100).round();
  SubmissionStatus get submissionStatus => _submissionStatus;

  Future<void> loadSadaqahList() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sadaqah_orgs')
          .where('status', isEqualTo: 'paid')
          .where('paid', isEqualTo: true)
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

      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(days: 7));

      final oldNotifications = await FirebaseFirestore.instance
          .collection('notifications')
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoff))
          .get();

      for (var doc in oldNotifications.docs) {
        await doc.reference.delete();
      }

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'New Sadaqah Submission',
        'message':
            '${user?.email ?? "A user"} submitted a new organization: ${sadaqah.organization}',
        'timestamp': Timestamp.fromDate(now),
        'recipientRole': 'super_admin',
        'read': false,
        'sadaqahId': docRef.id,
      });

      await loadSadaqahList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding sadaqah: $e");
    }
  }

  void setFilterCategory(String category) {
    _filterCategory = category;
    _filterByCategory();
    notifyListeners();
  }

  void _filterByCategory() {
    if (_filterCategory == "All") {
      _filteredSadaqah = _allSadaqah;
    } else {
      _filteredSadaqah = _allSadaqah.where((s) {
        return s.category.toLowerCase() == _filterCategory.toLowerCase();
      }).toList();
    }
  }

  void setFormCategory(String category) {
    _formCategory = category;
    notifyListeners();
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
      _email = user.email;
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
          .update({'status': 'pending to pay', 'paid': false});

      final submission = await FirebaseFirestore.instance
          .collection('sadaqah_orgs')
          .doc(id)
          .get();

      final data = submission.data();
      if (data == null) return "Submission not found";

      final organization = data['organization'] ?? 'organization';
      final submittedBy = data['submittedBy'];
      final submitterRole = data['role'] ?? 'user';

      if (submittedBy == null) {
        return "No user to notify";
      }

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'Sadaqah Payment Required',
        'message':
            'Please proceed to pay for the approved organization: $organization',
        'timestamp': FieldValue.serverTimestamp(),
        'recipientRole': submitterRole,
        'recipientId': submittedBy,
        'read': false,
        'sadaqahId': id,
      });

      return "Approved & notification sent to submitter";
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

  Future<String> paySadaqah(String sadaqahId) async {
    try {
      await FirebaseFirestore.instance
          .collection('sadaqah_orgs')
          .doc(sadaqahId)
          .update({'status': 'paid', 'paid': true});

      await loadSadaqahList();
      return "Payment successful";
    } catch (e) {
      debugPrint("Error paying sadaqah: $e");
      return "Payment failed";
    }
  }

  Future<String> unsubscribeSadaqah(String id) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return "User not logged in";

      final docRef = FirebaseFirestore.instance
          .collection('sadaqah_orgs')
          .doc(id);
      final doc = await docRef.get();

      if (!doc.exists) return "Submission not found";

      final submittedBy = doc.data()?['submittedBy'] ?? '';

      if (submittedBy != user.uid) {
        return "You can only unsubscribe your own submissions";
      }

      await docRef.delete();
      await loadSadaqahList();

      return "Unsubscribed successfully";
    } catch (e) {
      debugPrint("Error unsubscribing: $e");
      return "Failed to unsubscribe";
    }
  }
}
