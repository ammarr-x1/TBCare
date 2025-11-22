import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/screening_model.dart';
import '../models/ai_case_model.dart';

class ScreeningService {
  static final _firestore = FirebaseFirestore.instance;

  /// Fetch all screenings for a specific patient
  static Future<List<ScreeningModel>> fetchScreeningsForPatient(
    String patientId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('screenings')
          .orderBy('date', descending: true) // ✅ keeping your schema
          .get();

      return snapshot.docs
          .map((doc) => ScreeningModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching screenings for $patientId: $e");
      return [];
    }
  }

  /// Fetch AI-flagged cases for doctor dashboard
  static Future<List<AiCaseModel>> fetchAiCasesForDoctorDashboard({
    int limitPerPatient = 1,
  }) async {
    final List<AiCaseModel> allCases = [];

    try {
      final patientsSnapshot = await _firestore.collection('patients').get();

      for (final patientDoc in patientsSnapshot.docs) {
        final patientId = patientDoc.id;
        final patientName = patientDoc['name'] ?? '';

        final screeningsSnapshot = await patientDoc.reference
            .collection('screenings')
            .orderBy('date', descending: true) // ✅ keeping your schema
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
            print("Error parsing screening for $patientId: $e");
          }
        }
      }

      allCases.sort((a, b) => b.date.compareTo(a.date));
      return allCases;
    } catch (e) {
      print("Error fetching AI cases: $e");
      return [];
    }
  }

  /// Create a new screening under a patient
  static Future<void> createScreening({
    required String patientId,
    required String screeningId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final docRef = _firestore
          .collection('patients')
          .doc(patientId)
          .collection('screenings')
          .doc(screeningId);

      await docRef.set({
        ...data,
        'screeningId': screeningId,
        'date': Timestamp.now(), // ✅ metadata
      });
    } catch (e) {
      print("Error creating screening for $patientId: $e");
    }
  }
}
