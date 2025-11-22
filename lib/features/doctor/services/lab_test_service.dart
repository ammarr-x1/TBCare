import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lab_test_model.dart';

class LabTestService {
  static final _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _labTestsRef(
    String patientId,
    String screeningId,
  ) {
    return _firestore
        .collection('patients')
        .doc(patientId)
        .collection('screenings')
        .doc(screeningId)
        .collection('labTests');
  }

  /// Create a new lab test document
  static Future<void> createLabTest({
    required String patientId,
    required String screeningId,
    required LabTestModel test,
  }) async {
    try {
      await _labTestsRef(patientId, screeningId)
          .doc(test.labTestId)
          .set(test.toMap());
    } catch (e) {
      print('❌ Error creating lab test: $e');
      rethrow;
    }
  }

  /// Get all lab tests for a given screening
  static Future<List<LabTestModel>> getLabTests({
    required String patientId,
    required String screeningId,
  }) async {
    try {
      final snapshot = await _labTestsRef(patientId, screeningId)
          .orderBy('requestedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => LabTestModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ Error fetching lab tests: $e');
      rethrow;
    }
  }

  /// Update the status of a specific lab test
  static Future<void> updateLabTestStatus({
    required String patientId,
    required String screeningId,
    required String labTestId,
    required String status, // Pending / Uploaded
    String? fileUrl,
    String? comments,
  }) async {
    try {
      final updateData = {
        'status': status,
        if (fileUrl != null) 'fileUrl': fileUrl,
        if (comments != null) 'comments': comments,
        if (status == 'Uploaded') 'uploadedAt': Timestamp.now(),
      };

      await _labTestsRef(patientId, screeningId)
          .doc(labTestId)
          .update(updateData);
    } catch (e) {
      print('❌ Error updating lab test $labTestId: $e');
      rethrow;
    }
  }
}
