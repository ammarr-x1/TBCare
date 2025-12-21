import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/patient_model.dart';

class PatientService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _patientsRef =>
      _firestore.collection('patients');

  /// Get current logged-in doctor's ID
  static String? get _currentDoctorId => _auth.currentUser?.uid;

  /// Fetch all patients assigned to the logged-in doctor
  static Future<List<PatientModel>> fetchAllPatients() async {
    try {
      final doctorId = _currentDoctorId;
      if (doctorId == null) {
        throw Exception('No authenticated doctor found');
      }

      final snapshot = await _patientsRef
          .where('selectedDoctor', isEqualTo: doctorId)
          .get();

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

  /// Fetch a single patient by ID (only if assigned to logged-in doctor)
  static Future<PatientModel?> fetchPatientById(String patientId) async {
    try {
      final doctorId = _currentDoctorId;
      if (doctorId == null) {
        throw Exception('No authenticated doctor found');
      }

      final doc = await _patientsRef.doc(patientId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      
      // HIPAA: Verify patient belongs to this doctor
      if (data['selectedDoctor'] != doctorId) {
        print("⚠️ Access denied: Patient not assigned to this doctor");
        return null;
      }

      data['uid'] = data['uid'] ?? doc.id;
      return PatientModel.fromMap(data);
    } catch (e) {
      print("❌ Error fetching patient $patientId: $e");
      rethrow;
    }
  }

  /// Stream only patients with confirmed TB (assigned to logged-in doctor)
  static Stream<List<PatientModel>> fetchTBPatientsStream() {
    final doctorId = _currentDoctorId;
    if (doctorId == null) {
      return Stream.value([]);
    }

    return _patientsRef
        .where('selectedDoctor', isEqualTo: doctorId)
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

  /// Get the latest screening ID for a given patient (with ownership check)
  static Future<String?> fetchLatestScreeningId(String patientId) async {
    try {
      final doctorId = _currentDoctorId;
      if (doctorId == null) {
        throw Exception('No authenticated doctor found');
      }

      // First verify patient belongs to this doctor
      final patientDoc = await _patientsRef.doc(patientId).get();
      if (!patientDoc.exists) return null;
      
      if (patientDoc.data()?['selectedDoctor'] != doctorId) {
        print("⚠️ Access denied: Patient not assigned to this doctor");
        return null;
      }

      final snapshot = await _patientsRef
          .doc(patientId)
          .collection('screenings')
          .orderBy('timestamp', descending: true)
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