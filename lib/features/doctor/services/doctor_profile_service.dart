import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:tbcare_main/features/doctor/models/doctor_profile_model.dart';

class DoctorProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current doctor profile
  Stream<Doctor?> getCurrentDoctorProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('doctors')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return Doctor.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // Get doctor by ID
  Future<Doctor?> getDoctorById(String doctorId) async {
    try {
      final doc = await _firestore.collection('doctors').doc(doctorId).get();
      if (doc.exists) {
        return Doctor.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get doctor profile: $e');
    }
  }

  // Update doctor profile
  Future<void> updateDoctorProfile(Doctor doctor) async {
    try {
      await _firestore
          .collection('doctors')
          .doc(doctor.uid)
          .update(doctor.toFirestore());
    } catch (e) {
      throw Exception('Failed to update doctor profile: $e');
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(File imageFile, String doctorId) async {
    try {
      final ref = _storage.ref().child('doctor_profiles').child('$doctorId.jpg');
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Update profile image
  Future<void> updateProfileImage(String doctorId, File imageFile) async {
    try {
      final imageUrl = await uploadProfileImage(imageFile, doctorId);
      await _firestore.collection('doctors').doc(doctorId).update({
        'profileImageUrl': imageUrl,
      });
    } catch (e) {
      throw Exception('Failed to update profile image: $e');
    }
  }

  // Get doctor statistics
  Future<Map<String, dynamic>> getDoctorStatistics(String doctorId) async {
    try {
      final doc = await _firestore.collection('doctors').doc(doctorId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'totalPatientsReviewed': data['totalPatientsReviewed'] ?? 0,
          'totalDiagnosisMade': data['totalDiagnosisMade'] ?? 0,
          'totalFinalVerdicts': data['totalFinalVerdicts'] ?? 0,
          'confirmedTBCount': data['confirmedTBCount'] ?? 0,
          'totalRecommendationGiven': data['totalRecommendationGiven'] ?? 0,
          'totalTestsRequested': data['totalTestsRequested'] ?? 0,
        };
      }
      return {};
    } catch (e) {
      throw Exception('Failed to get doctor statistics: $e');
    }
  }

  // Get recent diagnoses
  Future<List<Map<String, dynamic>>> getRecentDiagnoses(String doctorId, {int limit = 5}) async {
    try {
      final querySnapshot = await _firestore
          .collection('diagnoses')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('requestedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'diagnosisId': doc.id,
          'patientId': data['patientId'],
          'finalDiagnosis': data['finalDiagnosis'],
          'requestedAt': data['requestedAt'],
          'screeningId': data['screeningId'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get recent diagnoses: $e');
    }
  }

  // Update doctor statistics (called when doctor completes actions)
  Future<void> incrementStatistic(String doctorId, String statisticName) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).update({
        statisticName: FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to update statistic: $e');
    }
  }

  // Get all doctors (for admin or referral purposes)
  Future<List<Doctor>> getAllDoctors() async {
    try {
      final querySnapshot = await _firestore
          .collection('doctors')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Doctor.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all doctors: $e');
    }
  }

  // Search doctors by specialization
  Future<List<Doctor>> getDoctorsBySpecialization(String specialization) async {
    try {
      final querySnapshot = await _firestore
          .collection('doctors')
          .where('specialization', isEqualTo: specialization)
          .get();

      return querySnapshot.docs
          .map((doc) => Doctor.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get doctors by specialization: $e');
    }
  }
}