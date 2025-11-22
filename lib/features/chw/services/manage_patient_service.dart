import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tbcare_main/features/chw/models/manage_patient_model.dart';

class PatientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a new patientId (uid)
  String newPatientId(String chwId) {
    return _firestore
        .collection("chws")
        .doc(chwId)
        .collection("assigned_patients")
        .doc()
        .id;
  }

  Future<void> addPatient(Patient patient, String chwId) async {
    DocumentReference patientRef = _firestore
        .collection("chws")
        .doc(chwId)
        .collection("assigned_patients")
        .doc(patient.id);

    await patientRef.set(patient.toMap());
  }
}
