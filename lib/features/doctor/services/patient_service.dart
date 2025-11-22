import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';

class PatientService {
  static final _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _patientsRef =>
      _firestore.collection('patients');

  /// Fetch all patients once
  static Future<List<PatientModel>> fetchAllPatients() async {
    try {
      final snapshot = await _patientsRef.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = data['uid'] ?? doc.id;
        return PatientModel.fromMap(data);
      }).toList();
    } catch (e) {
      print("❌ Error fetching patients: $e");
      rethrow;
    }
  }

  /// Fetch a single patient by ID
  static Future<PatientModel?> fetchPatientById(String patientId) async {
    try {
      final doc = await _patientsRef.doc(patientId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['uid'] = data['uid'] ?? doc.id;
      return PatientModel.fromMap(data);
    } catch (e) {
      print("❌ Error fetching patient $patientId: $e");
      rethrow;
    }
  }

  /// Stream only patients with confirmed TB
  static Stream<List<PatientModel>> fetchTBPatientsStream() {
    return _patientsRef
        .where('diagnosisStatus', isEqualTo: 'TB')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = data['uid'] ?? doc.id;
        return PatientModel.fromMap(data);
      }).toList();
    });
  }

  /// Get the latest screening ID for a given patient
  static Future<String?> fetchLatestScreeningId(String patientId) async {
    try {
      final snapshot = await _patientsRef
          .doc(patientId)
          .collection('screenings')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.id;
    } catch (e) {
      print("❌ Error fetching latest screening for $patientId: $e");
      rethrow;
    }
  }
}
