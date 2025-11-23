import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/screening_model.dart';
import '../models/ai_case_model.dart';

class ScreeningService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _patientsRef =>
      _firestore.collection('patients');

  /// Get current logged-in doctor's ID
  static String? get _currentDoctorId => _auth.currentUser?.uid;

  /// Verify patient belongs to logged-in doctor
  static Future<bool> _verifyPatientOwnership(String patientId) async {
    final doctorId = _currentDoctorId;
    if (doctorId == null) return false;

    final patientDoc = await _patientsRef.doc(patientId).get();
    if (!patientDoc.exists) return false;

    return patientDoc.data()?['selectedDoctor'] == doctorId;
  }

  /// Fetch all screenings for a specific patient (with ownership check)
  static Future<List<ScreeningModel>> fetchScreeningsForPatient(
    String patientId,
  ) async {
    try {
      // HIPAA: Verify patient belongs to this doctor
      final hasAccess = await _verifyPatientOwnership(patientId);
      if (!hasAccess) {
        print("⚠️ Access denied: Patient not assigned to this doctor");
        return [];
      }

      final snapshot = await _patientsRef
          .doc(patientId)
          .collection('screenings')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ScreeningModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("❌ Error fetching screenings for $patientId: $e");
      return [];
    }
  }

  /// Fetch AI-flagged cases for doctor dashboard (only assigned patients)
  static Future<List<AiCaseModel>> fetchAiCasesForDoctorDashboard({
    int limitPerPatient = 1,
  }) async {
    final List<AiCaseModel> allCases = [];

    try {
      final doctorId = _currentDoctorId;
      if (doctorId == null) {
        print("⚠️ No authenticated doctor found");
        return [];
      }

      // HIPAA: Only fetch patients assigned to this doctor
      final patientsSnapshot = await _patientsRef
          .where('selectedDoctor', isEqualTo: doctorId)
          .get();

      for (final patientDoc in patientsSnapshot.docs) {
        final patientId = patientDoc.id;
        final patientName = patientDoc['name'] ?? '';

        final screeningsSnapshot = await patientDoc.reference
            .collection('screenings')
            .orderBy('date', descending: true)
            .limit(limitPerPatient)
            .get();

        for (final screeningDoc in screeningsSnapshot.docs) {
          try {
            final caseModel = AiCaseModel.fromFirestore(
              screeningDoc,
              patientId,
              patientName,
            );
            allCases.add(caseModel);
          } catch (e) {
            print("❌ Error parsing screening for $patientId: $e");
          }
        }
      }

      allCases.sort((a, b) => b.date.compareTo(a.date));
      return allCases;
    } catch (e) {
      print("❌ Error fetching AI cases: $e");
      return [];
    }
  }

  /// Create a new screening under a patient (with ownership check)
  static Future<bool> createScreening({
    required String patientId,
    required String screeningId,
    required Map<String, dynamic> data,
  }) async {
    try {
      // HIPAA: Verify patient belongs to this doctor
      final hasAccess = await _verifyPatientOwnership(patientId);
      if (!hasAccess) {
        print("⚠️ Access denied: Patient not assigned to this doctor");
        return false;
      }

      final docRef = _patientsRef
          .doc(patientId)
          .collection('screenings')
          .doc(screeningId);

      await docRef.set({
        ...data,
        'screeningId': screeningId,
        'date': Timestamp.now(),
      });

      return true;
    } catch (e) {
      print("❌ Error creating screening for $patientId: $e");
      return false;
    }
  }
}