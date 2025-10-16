import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ramadhan_companion_app/model/masjid_programme_model.dart';

class MasjidProgrammeProvider extends ChangeNotifier {
  final masjidController = TextEditingController();
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final joinLinkController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  MasjidProgrammeProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadProgrammes();
  }

  List<MasjidProgramme> _allProgrammes = [];
  List<MasjidProgramme> get allProgrammes => _allProgrammes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime? dateTime;
  bool isOnline = false;
  String? posterBase64;
  // double oneOffAmount = 6.90;

  String _masjidQuery = '';
  String _stateQuery = '';

  bool get isFormValid =>
      masjidController.text.trim().isNotEmpty &&
      titleController.text.trim().isNotEmpty &&
      dateTime != null;
  // int get oneOffAmountInCents => (oneOffAmount * 100).round();

  Future<void> pickPoster() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final compressed = await FlutterImageCompress.compressWithFile(
        picked.path,
        minWidth: 600,
        minHeight: 600,
        quality: 50,
      );
      if (compressed != null) {
        posterBase64 = base64Encode(compressed);
        notifyListeners();
      }
    }
  }

  Future<void> loadProgrammes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('masjidProgrammes').get();
      final now = DateTime.now();

      _allProgrammes = snapshot.docs.map((doc) {
        final data = doc.data();
        final programmeTime = DateTime.parse(data['dateTime']);
        String status = data['status'] ?? 'pending';

        // Automatically mark expired programmes 1h after dateTime
        if (programmeTime.add(const Duration(hours: 1)).isBefore(now)) {
          status = 'expired';
          doc.reference.update({'status': 'expired'});
        }

        final posterBase64 = data['posterUrl'] as String?;

        return MasjidProgramme(
          id: doc.id,
          masjidName: data['masjidName'] ?? '',
          title: data['title'] ?? '',
          dateTime: programmeTime,
          isOnline: data['isOnline'] ?? false,
          location: data['location'],
          joinLink: data['joinLink'],
          posterUrl: posterBase64,
          posterBytes: posterBase64 != null ? base64Decode(posterBase64) : null,
          status: status,
        );
      }).toList();

      _allProgrammes = _allProgrammes
          .where((p) => p.status != 'expired')
          .toList();
    } catch (e) {
      debugPrint("Error loading programmes: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> addProgramme() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final programme = MasjidProgramme(
        id: '',
        masjidName: masjidController.text.trim(),
        title: titleController.text.trim(),
        dateTime: dateTime!,
        isOnline: isOnline,
        location: isOnline ? null : locationController.text.trim(),
        joinLink: isOnline ? joinLinkController.text.trim() : null,
        posterUrl: posterBase64,
        posterBytes: posterBase64 != null ? base64Decode(posterBase64!) : null,
      );

      final data = {
        "masjidName": programme.masjidName,
        "title": programme.title,
        "dateTime": programme.dateTime.toIso8601String(),
        "isOnline": programme.isOnline,
        "location": programme.location,
        "joinLink": programme.joinLink,
        "submittedAt": FieldValue.serverTimestamp(),
        "status": "pending",
        "submittedBy": user.uid,
        if (programme.posterUrl != null) "posterUrl": programme.posterUrl,
      };

      final docRef = await _firestore.collection('masjidProgrammes').add(data);

      debugPrint("✅ Programme added with ID: ${docRef.id}");

      await docRef.update({"id": docRef.id});

      resetForm();
      notifyListeners();

      return docRef.id;
    } catch (e) {
      debugPrint("❌ Error adding programme: $e");
      return null;
    }
  }

  Future<String> removeProgramme(String id, {String? reason}) async {
    try {
      final programmeDoc = await _firestore
          .collection('masjidProgrammes')
          .doc(id)
          .get();

      if (!programmeDoc.exists) {
        return "Programme not found";
      }

      final data = programmeDoc.data();
      final submittedBy = data?['submittedBy'];
      final title = data?['title'] ?? 'Programme';

      await _firestore.collection('masjidProgrammes').doc(id).update({
        'status': 'rejected',
        'rejection_reason': reason ?? 'No reason provided',
      });

      if (submittedBy != null) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'title': "Programme Rejected",
          'message':
              "Your programme '$title' was rejected. Reason: ${reason ?? 'No reason provided'}. Please submit a new one.",
          'recipientId': submittedBy,
          'recipientRole': "user",
          'programmeId': id,
          'read': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      await _firestore.collection('masjidProgrammes').doc(id).delete();

      await loadProgrammes();
      return "Programme rejected and user notified";
    } catch (e) {
      debugPrint("Error rejecting programme: $e");
      return "Failed to reject programme";
    }
  }

  void filterByMasjid(String query) {
    _masjidQuery = query.toLowerCase();
    notifyListeners();
  }

  void filterByState(String query) {
    _stateQuery = query.toLowerCase();
    notifyListeners();
  }

  List<MasjidProgramme> get filteredProgrammes {
    return _allProgrammes.where((p) {
      final masjidMatch = p.masjidName.toLowerCase().contains(_masjidQuery);
      final stateMatch = (p.location ?? '').toLowerCase().contains(_stateQuery);
      return masjidMatch && stateMatch;
    }).toList();
  }

  void resetForm() {
    masjidController.clear();
    titleController.clear();
    locationController.clear();
    joinLinkController.clear();
    dateTime = null;
    isOnline = false;
    posterBase64 = null;
    notifyListeners();
  }

  @override
  void dispose() {
    masjidController.dispose();
    titleController.dispose();
    locationController.dispose();
    joinLinkController.dispose();
    super.dispose();
  }
}
