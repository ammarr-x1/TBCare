import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tbcare_main/features/chw/models/chw_dashboard_patient_model.dart';

class CHWDashboardService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User get currentUser => _auth.currentUser!;

  CollectionReference<Map<String, dynamic>> get _chwDoc =>
      _firestore.collection('chws');

  DocumentReference<Map<String, dynamic>> get _meDoc =>
      _chwDoc.doc(currentUser.uid);

  CollectionReference<Map<String, dynamic>> get _assignedPatients =>
      _meDoc.collection('assigned_patients');

  /// Count total patients
  Future<int> countPatients() async {
    final snap = await _assignedPatients.get();
    return snap.size;
  }

  /// Stream all screenings for this CHW
  Stream<List<Map<String, dynamic>>> screeningsStream() {
    return _firestore
        .collection('screenings')
        .where('chwId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  /// Dashboard counts (does NOT include lab test counts)
  Stream<Map<String, int>> dashboardCounts() {
    return _assignedPatients.snapshots().asyncMap((assignedSnap) async {
      int aiFlagged = 0;
      int followUps = 0;
      int referrals = 0;
      int confirmed = 0;
      int screenings = 0;

      for (var p in assignedSnap.docs) {
        final patientId = p.id;

        final screeningSnap = await _firestore
            .collection('screenings')
            .where('chwId', isEqualTo: currentUser.uid)
            .where('patientId', isEqualTo: patientId)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (screeningSnap.docs.isNotEmpty) {
          final data = screeningSnap.docs.first.data();
          screenings++;

          // AI flagged: any patient screened
          aiFlagged++;

          // Follow-ups: increment only when explicitly sent to doctor
          if (data['followUpNeeded'] == true &&
              data['followUpStatus'] == 'sent_to_doctor') {
            followUps++;
          }

          // Referrals
          if (data['referred'] == true) referrals++;

          // Confirmed TB
          if (data['confirmed'] == true) confirmed++;
        }
      }

      return {
        'aiFlagged': aiFlagged,
        'followUps': followUps,
        'referrals': referrals,
        'confirmed': confirmed,
        'screenings': screenings,
      };
    });
  }

  /// Separate count for Lab Tests (status == "Needs Lab Test")
  Stream<int> labTestCount() {
    return _assignedPatients.snapshots().asyncMap((assignedSnap) async {
      int labTests = 0;

      for (var p in assignedSnap.docs) {
        final patientId = p.id;

        // Query inside patients/{patientId}/screenings
        final screeningsSnap = await _firestore
            .collection('patients')
            .doc(patientId)
            .collection('screenings')
            .where('status', isEqualTo: 'Needs Lab Test')
            .get();

        labTests += screeningsSnap.size;
      }

      return labTests;
    });
  }

  /// Recent activity table
  Stream<List<RecentActivity>> recentActivity() {
    return _assignedPatients.snapshots().asyncMap((assignedSnap) async {
      final List<RecentActivity> patientsWithStatus = [];

      for (var p in assignedSnap.docs) {
        final pdata = p.data();
        final patientId = p.id;

        final screeningSnap = await _firestore
            .collection('screenings')
            .where('chwId', isEqualTo: currentUser.uid)
            .where('patientId', isEqualTo: patientId)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        String status = "New (Not Screened)";
        int? statusColor;
        DateTime? date;

        if (screeningSnap.docs.isNotEmpty) {
          final data = screeningSnap.docs.first.data();
          date = (data['timestamp'] as Timestamp?)?.toDate();

          if (data['referred'] == true) {
            status = "Referred to Facility";
            statusColor = 0xFF2697FF;
          } else if (data['followUpNeeded'] == true &&
              data['followUpStatus'] == 'completed') {
            status = "Follow-up Completed";
            statusColor = 0xFF00FF00;
          } else if (data['followUpNeeded'] == true &&
              data['followUpStatus'] != 'completed') {
            status = "Follow-up Pending";
            statusColor = 0xFFFFC857;
          } else if (data['confirmed'] == true) {
            status = "Confirmed TB Case";
            statusColor = 0xFFEF476F;
          } else {
            status = "Screened";
            statusColor = 0xFFB0BEC5;
          }
        } else {
          date = (pdata['createdAt'] as Timestamp?)?.toDate();
        }

        patientsWithStatus.add(RecentActivity(
          name: pdata['name'] ?? 'Unknown',
          status: status,
          statusColor: statusColor,
          date: date,
        ));
      }

      patientsWithStatus.sort((a, b) {
        final da = a.date;
        final db = b.date;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });

      return patientsWithStatus;
    });
  }
}
