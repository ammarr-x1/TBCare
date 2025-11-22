import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tbcare_main/features/chw/models/flagged_patients_model.dart';

class ScreeningService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String chwId = FirebaseAuth.instance.currentUser!.uid;

  /// 🔹 Stream of AI-flagged patients
  Stream<List<Screening>> getFlaggedPatients() {
    return _firestore
        .collection("screenings")
        .where("chwId", isEqualTo: chwId)
        .where("flaggedByAI", isEqualTo: true)
        .where("followUpNeeded", isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Screening.fromMap(doc.id, doc.data())).toList());
  }

  /// 🔹 Stream of all screenings
  Stream<List<Screening>> getAllScreenings() {
    return _firestore
        .collection("screenings")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Screening.fromMap(doc.id, doc.data())).toList());
  }

  /// 🔹 Stream of follow-ups sent to doctor
  Stream<List<Screening>> getDoctorFollowUps() {
    return _firestore
        .collection("screenings")
        .where("chwId", isEqualTo: chwId)
        .where("followUpStatus", isEqualTo: "sent_to_doctor")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Screening.fromMap(doc.id, doc.data())).toList());
  }

  /// 🔹 Send patient to doctor in Ammar format
  Future<void> sendToDoctor(Screening screening) async {
    final patientRef = _firestore.collection("patients").doc(screening.patientId);

    // 1️⃣ Fetch full patient info from CHW assigned_patients
    final assignedPatientDoc = await _firestore
        .collection("chws")
        .doc(chwId)
        .collection("assigned_patients")
        .doc(screening.patientId)
        .get();

    if (!assignedPatientDoc.exists) {
      throw Exception("Patient not found in assigned_patients");
    }

    final patientData = assignedPatientDoc.data()!;

    // 2️⃣ Prepare full patient document
    final patientDoc = {
      "uid": patientData['uid'] ?? screening.patientId,
      "patientId": screening.patientId,
      "name": patientData['name'] ?? screening.patientName,
      "age": patientData['age'] ?? null,
      "weight": patientData['weight'] ?? null,
      "gender": patientData['gender'] ?? "",
      "address": patientData['address'] ?? "",
      "phone": patientData['phone'] ?? "",
      "language": patientData['language'] ?? "English",
      "appetite": patientData['appetite'] ?? "",
      "comorbidities": patientData['comorbidities'] ?? "",
      "medicationHistory": patientData['medicationHistory'] ?? "",
      "imageUrl": patientData['imageUrl'] ?? null,
      "diagnosisStatus": "Needs Doctor Review",
      "createdAt": patientData['createdAt'] ?? FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    };

    // 3️⃣ Prepare screening subcollection
    final screeningDoc = {
      "screeningId": screening.id,
      "submittedBy": chwId,
      "diagnosedBy": chwId,
      "aiPrediction": screening.aiPrediction ?? {"Normal": "0.0", "TB": "0.0"},
      "coughAudioPath": screening.coughAudioPath ?? null,
      "media": screening.media ?? {"coughUrl": "", "xrayUrl": ""},
      "symptoms": {for (var s in screening.symptoms ?? []) s: true},
      "finalDiagnosis": "",
      "status": "Needs Doctor Review",
      "timestamp": screening.timestamp ?? FieldValue.serverTimestamp(),
      "date": screening.timestamp ?? FieldValue.serverTimestamp(),
    };

    // 4️⃣ Save patient doc & screening subcollection
    await patientRef.set(patientDoc, SetOptions(merge: true));
    await patientRef.collection("screenings").doc(screening.id).set(screeningDoc);

    // 5️⃣ Update main screenings collection
    await _firestore.collection("screenings").doc(screening.id).update({
      "followUpStatus": "sent_to_doctor",
      "followUpNeeded": true,
      "status": "sent_to_doctor",
      "flaggedByAI": false,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// 🔹 Refer patient to hospital
  Future<void> referToHospital(Screening screening) async {
    final patientRef = _firestore.collection("patients").doc(screening.patientId);

    // 1️⃣ Fetch full patient info from CHW assigned_patients
    final assignedPatientDoc = await _firestore
        .collection("chws")
        .doc(chwId)
        .collection("assigned_patients")
        .doc(screening.patientId)
        .get();

    if (!assignedPatientDoc.exists) {
      throw Exception("Patient not found in assigned_patients");
    }

    final patientData = assignedPatientDoc.data()!;

    // 2️⃣ Prepare top-level patient doc
    final patientDoc = {
      "uid": patientData['uid'] ?? screening.patientId,
      "patientId": screening.patientId,
      "name": patientData['name'] ?? screening.patientName,
      "age": patientData['age'] ?? null,
      "weight": patientData['weight'] ?? null,
      "gender": patientData['gender'] ?? "",
      "address": patientData['address'] ?? "",
      "phone": patientData['phone'] ?? "",
      "language": patientData['language'] ?? "English",
      "appetite": patientData['appetite'] ?? "",
      "comorbidities": patientData['comorbidities'] ?? "",
      "medicationHistory": patientData['medicationHistory'] ?? "",
      "imageUrl": patientData['imageUrl'] ?? null,
      "diagnosisStatus": "Referred to Hospital",
      "createdAt": patientData['createdAt'] ?? FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    };

    // 3️⃣ Add referral info in subcollection
    final referralDoc = {
      "symptoms": screening.symptoms,
      "timestamp": FieldValue.serverTimestamp(),
      "status": "referred_hospital",
    };

    // 4️⃣ Save patient doc & referral subcollection
    await patientRef.set(patientDoc, SetOptions(merge: true));
    await patientRef.collection("referrals").doc(screening.id).set(referralDoc);

    // 5️⃣ Update main screenings collection
    await _firestore.collection("screenings").doc(screening.id).update({
      "followUpStatus": "referred_hospital",
      "followUpNeeded": false,
      "status": "referred_hospital",
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
}
