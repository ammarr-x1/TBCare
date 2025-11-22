import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class LabTestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get current user ID
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Get patients needing lab test
  Stream<List<Map<String, dynamic>>> getPatientsNeedingLabTest() async* {
    final uid = currentUserId;
    if (uid == null) {
      yield [];
      return;
    }

    final assignedSnap = await _db
        .collection('chws')
        .doc(uid)
        .collection('assigned_patients')
        .get();

    final assignedPatientIds = assignedSnap.docs.map((doc) => doc.id).toList();
    if (assignedPatientIds.isEmpty) {
      yield [];
      return;
    }

    List<Map<String, dynamic>> result = [];

    for (var patientId in assignedPatientIds) {
      final patientDoc = await _db.collection('patients').doc(patientId).get();
      if (!patientDoc.exists) continue;

      final screeningsSnap = await _db
          .collection('patients')
          .doc(patientId)
          .collection('screenings')
          .where('status', isEqualTo: 'Needs Lab Test')
          .get();

      for (var screeningDoc in screeningsSnap.docs) {
        final data = Map<String, dynamic>.from(patientDoc.data()!);
        data['patientId'] = patientDoc.id;
        data['screeningId'] = screeningDoc.id;
        data['screeningData'] = screeningDoc.data();
        result.add(data);
      }
    }

    yield result;
  }

  /// 📂 Pick file (Ali style - using image picker)
  Future<File?> pickFile() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print("❌ File pick error: $e");
    }
    return null;
  }

  /// ☁️ Upload file to Cloudinary
  Future<String> uploadToCloudinary(File file) async {
    const cloudName = 'de1oz7jbg';
    const uploadPreset = 'upload_tests'; // 🔹 Make sure this exists in Cloudinary

    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/auto/upload");

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", file.path));

    final response = await request.send();
    final resStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(resStr);
      return jsonRes["secure_url"];
    } else {
      throw Exception("Cloudinary upload failed: $resStr");
    }
  }

  /// 💾 Save lab test record in Firestore
  Future<void> saveLabTest({
    required String patientId,
    required String screeningId,
    required String testName,
    required String fileUrl,
  }) async {
    final labTestId = _db.collection('patients').doc().id;

    final labTestData = {
      "labTestId": labTestId,
      "testName": testName,
      "status": "Pending",
      "comments": "",
      "fileUrl": fileUrl,
      "requestedAt": FieldValue.serverTimestamp(),
      "uploadedAt": FieldValue.serverTimestamp(),
    };

    await _db
        .collection('patients')
        .doc(patientId)
        .collection('screenings')
        .doc(screeningId)
        .collection('labTests')
        .doc(labTestId)
        .set(labTestData);
  }
}
