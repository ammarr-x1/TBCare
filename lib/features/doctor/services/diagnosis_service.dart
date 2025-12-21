import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/diagnosis_model.dart';
import '../models/lab_test_model.dart';
import 'doctor_service.dart';

class DiagnosisService {
  static final _firestore = FirebaseFirestore.instance;
  static final _uuid = const Uuid();

  static CollectionReference<Map<String, dynamic>> _patientRef(String patientId) =>
      _firestore.collection('patients').doc(patientId).collection('screenings');

  /// Save doctor’s initial diagnosis (with/without lab test request)
  static Future<void> saveDiagnosisAndLabTest({
    required String patientId,
    required String screeningId,
    required String doctorId,
    required String diagnosis, // TB / Not TB / Needs Lab Test
    String? notes,
    String? requestedTest,
  }) async {
    try {
      final diagnosisId = _uuid.v4();
      final diagnosisRef = _patientRef(patientId)
          .doc(screeningId)
          .collection('diagnosis')
          .doc(diagnosisId);

      final screeningRef = _patientRef(patientId).doc(screeningId);
      final patientRef = _firestore.collection('patients').doc(patientId);

      final batch = _firestore.batch();

      // Create diagnosis entry
      final diagnosisModel = DiagnosisModel(
        diagnosisId: diagnosisId,
        doctorId: doctorId,
        status: diagnosis == 'Needs Lab Test' ? 'Needs Lab Test' : diagnosis,
        notes: notes,
        requestedTests: requestedTest != null ? [requestedTest] : [],
        reviewable: diagnosis == 'Needs Lab Test',
        verdictGiven: diagnosis != 'Needs Lab Test',
        createdAt: DateTime.now(),
      );
      batch.set(diagnosisRef, diagnosisModel.toMap());

      // If lab test requested
      bool labTestRequested = false;
      if (diagnosis == 'Needs Lab Test' && requestedTest != null) {
        final labTestId = _uuid.v4();
        final labTestRef = screeningRef.collection('labTests').doc(labTestId);

        final labTestModel = LabTestModel(
          labTestId: labTestId,
          testName: requestedTest,
          fileUrl: null,
          status: 'Pending',
          comments: null,
          requestedAt: DateTime.now(),
          uploadedAt: null,
        );
        batch.set(labTestRef, labTestModel.toMap());
        labTestRequested = true;
      }

      // Update screening
      batch.update(screeningRef, {
        'status': diagnosis == 'Needs Lab Test' ? 'Needs Lab Test' : diagnosis,
        'finalDiagnosis': diagnosis == 'Needs Lab Test' ? null : diagnosis,
        'doctorDiagnosis': diagnosis == 'Needs Lab Test' ? null : diagnosis, // Added as requested
        'diagnosedBy': doctorId,
      });

      // Update patient status if final
      if (diagnosis != 'Needs Lab Test') {
        batch.update(patientRef, {'diagnosisStatus': diagnosis});
      }

      await batch.commit();

      // 🔗 Update doctor stats
      await DoctorService.recordDiagnosis(
        diagnosisId: diagnosisId,
        finalDiagnosis: diagnosis,
        patientId: patientId,
        screeningId: screeningId,
        labTestRequested: labTestRequested,
      );
    } catch (e) {
      print('❌ Error saving diagnosis: $e');
      rethrow;
    }
  }

  /// Update final verdict after reviewing lab results
  static Future<void> updateFinalVerdict({
    required String patientId,
    required String screeningId,
    required String doctorId,
    required String status, // TB / Not TB
    String? notes,
  }) async {
    try {
      final diagnosisCollection =
          _patientRef(patientId).doc(screeningId).collection('diagnosis');

      final diagnosisSnapshot = await diagnosisCollection
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (diagnosisSnapshot.docs.isEmpty) {
        throw Exception('No diagnosis found to update');
      }

      final diagnosisRef = diagnosisSnapshot.docs.first.reference;
      final screeningRef = _patientRef(patientId).doc(screeningId);
      final patientRef = _firestore.collection('patients').doc(patientId);

      final batch = _firestore.batch();

      // Update diagnosis doc
      batch.update(diagnosisRef, {
        'status': status,
        'notes': notes,
        'verdictGiven': true,
      });

      // Update screening doc
      batch.update(screeningRef, {
        'finalDiagnosis': status,
        'doctorDiagnosis': status, // Added as requested
        'status': status,
      });

      // Update patient
      batch.update(patientRef, {'diagnosisStatus': status});

      await batch.commit();

      // 🔗 Update doctor stats: Final verdict counter
      await _firestore.collection('doctors').doc(doctorId).update({
        'totalFinalVerdicts': FieldValue.increment(1),
      });
    } catch (e) {
      print('❌ Error updating final verdict: $e');
      rethrow;
    }
  }
}
