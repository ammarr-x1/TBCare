import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/doctor_stats.dart';

class DoctorService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _doctorId => _auth.currentUser?.uid;

  /// ---------------- READ: Dashboard stats ----------------
  static Future<Map<int, int>> fetchWeeklyDiagnoses() async {
    if (_doctorId == null) return {};

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final startOfPeriod = DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);

    try {
      final snapshot = await _firestore
          .collection('doctors')
          .doc(_doctorId)
          .collection('diagnoses')
          .where('createdAt', isGreaterThanOrEqualTo: startOfPeriod)
          .get();

      final Map<int, int> weeklyCounts = {
        0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0
      };

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['createdAt'] != null) {
          final date = (data['createdAt'] as Timestamp).toDate();
          final weekdayIndex = date.weekday - 1; 
          weeklyCounts[weekdayIndex] = (weeklyCounts[weekdayIndex] ?? 0) + 1;
        }
      }
      return weeklyCounts;
    } catch (e) {
      print("❌ Error fetching weekly diagnoses: $e");
      return {};
    }
  }

  /// ---------------- READ: Dashboard stats ----------------
  static Future<List<DoctorStat>> fetchDoctorStats() async {
    if (_doctorId == null) return [];
    try {
      final snapshot =
          await _firestore.collection('doctors').doc(_doctorId).get();

      final data = snapshot.data();
      if (data != null) {
        return [
          DoctorStat(
            label: "Patients",
            value: data['totalPatientsReviewed'] ?? 0,
            icon: "assets/icons/user.svg",
            color: const Color(0xFF007EE5),
          ),
          DoctorStat(
            label: "Screenings",
            value: data['totalDiagnosisMade'] ?? 0,
            icon: "assets/icons/clipboard.svg",
            color: const Color(0xFF26E5FF),
          ),
          DoctorStat(
            label: "Confirmed TB",
            value: data['confirmedTBCount'] ?? 0,
            icon: "assets/icons/check-shield.svg",
            color: const Color(0xFFEE2727),
          ),
          DoctorStat(
            label: "Recommendations",
            value: data['totalRecommendationGiven'] ?? 0,
            icon: "assets/icons/reports.svg",
            color: const Color(0xFF26C485),
          ),
        ];
      }
    } catch (e) {
      print("❌ Error fetching doctor stats: $e");
    }
    return [];
  }

  /// ---------------- WRITE: Record diagnosis ----------------
  static Future<void> recordDiagnosis({
    required String diagnosisId,
    required String finalDiagnosis,
    required String patientId,
    required String screeningId,
    bool labTestRequested = false,
  }) async {
    if (_doctorId == null) throw Exception("No logged-in doctor");

    final doctorRef = _firestore.collection('doctors').doc(_doctorId);
    final diagnosisRef = doctorRef.collection('diagnoses').doc(diagnosisId);

    final now = DateTime.now();
    final batch = _firestore.batch();

    // Log every diagnosis under doctor history
    batch.set(diagnosisRef, {
      'diagnosisId': diagnosisId,
      'finalDiagnosis': finalDiagnosis,
      'patientId': patientId,
      'screeningId': screeningId,
      'createdAt': now,
      'labTestRequested': labTestRequested,
    });

    // Increment stats with correct Firestore field names
    final counters = <String, Object>{
      'totalDiagnosisMade': FieldValue.increment(1),
      'patientsReviewed': FieldValue.arrayUnion([patientId]),
    };

    if (labTestRequested) {
      counters['totalTestsRequested'] = FieldValue.increment(1);
    }

    if (finalDiagnosis == 'TB') {
      counters['confirmedTBCount'] = FieldValue.increment(1);
    }

    batch.set(doctorRef, counters, SetOptions(merge: true));
    await batch.commit();

    // Update unique patient count
    await _updateTotalPatientsReviewed();
  }

  /// ---------------- WRITE: Update patient review count ----------------
  static Future<void> _updateTotalPatientsReviewed() async {
    if (_doctorId == null) return;

    final docRef = _firestore.collection('doctors').doc(_doctorId);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data() as Map<String, dynamic>;
      final patients = List<String>.from(data['patientsReviewed'] ?? []);
      await docRef.update({'totalPatientsReviewed': patients.length});
    }
  }

  /// ---------------- WRITE: Count recommendations ----------------
  static Future<void> incrementRecommendations() async {
    if (_doctorId == null) return;

    final doctorRef = _firestore.collection('doctors').doc(_doctorId);
    await doctorRef.update({
      'totalRecommendationGiven': FieldValue.increment(1),
    });
  }
}
