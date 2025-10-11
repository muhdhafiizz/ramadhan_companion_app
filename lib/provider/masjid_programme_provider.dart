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

  String _masjidQuery = '';
  String _stateQuery = '';

  bool get isFormValid =>
      masjidController.text.trim().isNotEmpty &&
      titleController.text.trim().isNotEmpty &&
      dateTime != null;

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
      final snapshot = await _firestore
          .collection('masjidProgrammes')
          .where('status', isEqualTo: 'approved')
          .get();

      _allProgrammes = snapshot.docs.map((doc) {
        final data = doc.data();
        final posterBase64 = data['posterUrl'] as String?;

        return MasjidProgramme(
          id: doc.id,
          masjidName: data['masjidName'] ?? '',
          title: data['title'] ?? '',
          dateTime: DateTime.parse(data['dateTime']),
          isOnline: data['isOnline'] ?? false,
          location: data['location'],
          joinLink: data['joinLink'],
          posterUrl: posterBase64,
          posterBytes: posterBase64 != null ? base64Decode(posterBase64) : null,
        );
      }).toList();
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

  Future<String> removeProgramme(String id) async {
    try {
      await _firestore.collection('masjidProgrammes').doc(id).delete();
      await loadProgrammes();
      return "Programme removed";
    } catch (e) {
      debugPrint("Error removing programme: $e");
      return "Failed to remove programme";
    }
  }

  // 🔹 Filters
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
