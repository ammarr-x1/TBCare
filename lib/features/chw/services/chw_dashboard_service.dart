import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Model for recent activity display
class RecentActivity {
  final String patientId;
  final String name;
  final String status;
  final int? statusColor;
  final DateTime? date;

  RecentActivity({
    required this.patientId,
    required this.name,
    required this.status,
    this.statusColor,
    this.date,
  });
}

/// Model for dashboard statistics
class DashboardStats {
  final int patients;
  final int screenings;
  final int aiFlagged;
  final int labTests;
  final int followUps;
  final int referrals;

  const DashboardStats({
    this.patients = 0,
    this.screenings = 0,
    this.aiFlagged = 0,
    this.labTests = 0,
    this.followUps = 0,
    this.referrals = 0,
  });
}

class CHWDashboardService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CHWDashboardService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _assignedPatients =>
      _firestore.collection('chws').doc(_currentUserId).collection('assigned_patients');

  /// Stream dashboard stats with optimized parallel fetching
  Stream<DashboardStats> dashboardStatsStream() {
    return _assignedPatients.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return const DashboardStats();
      }

      final patientIds = snapshot.docs.map((d) => d.id).toList();
      final patientCount = patientIds.length;

      // Fetch all screenings in parallel using Future.wait
      final screeningFutures = patientIds.map((patientId) {
        return _firestore
            .collection('patients')
            .doc(patientId)
            .collection('screenings')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();
      }).toList();

      final screeningResults = await Future.wait(screeningFutures);

      int screenings = 0;
      int aiFlagged = 0;
      int labTests = 0;
      int followUps = 0;
      int referrals = 0;

      for (final snap in screeningResults) {
        if (snap.docs.isEmpty) continue;

        final data = snap.docs.first.data();
        screenings++;

        // AI Flagged: check aiPrediction.TB > 0.5 (or your threshold)
        final aiPrediction = data['aiPrediction'] as Map<String, dynamic>?;
        if (aiPrediction != null) {
          final tbScore = double.tryParse(aiPrediction['TB']?.toString() ?? '0') ?? 0;
          if (tbScore > 0.5) aiFlagged++;
        }

        // Lab Tests: status == "Needs Lab Test"
        if (data['status'] == 'Needs Lab Test') labTests++;

        // Follow-ups: diagnosisStatus == "Pending" or specific followUp field
        final diagStatus = data['diagnosisStatus']?.toString().toLowerCase();
        if (diagStatus == 'pending') followUps++;

        // Referrals: check if referred field exists
        if (data['referred'] == true) referrals++;
      }

      return DashboardStats(
        patients: patientCount,
        screenings: screenings,
        aiFlagged: aiFlagged,
        labTests: labTests,
        followUps: followUps,
        referrals: referrals,
      );
    });
  }

  /// Stream recent activity with optimized fetching
  Stream<List<RecentActivity>> recentActivityStream({int limit = 10}) {
    return _assignedPatients.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return <RecentActivity>[];

      // Build patient info map and fetch screenings in parallel
      final futures = <Future<_PatientScreeningData>>[];

      for (final doc in snapshot.docs) {
        futures.add(_fetchPatientWithLatestScreening(doc));
      }

      final results = await Future.wait(futures);

      // Sort by date descending and limit
      results.sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return b.date!.compareTo(a.date!);
      });

      return results.take(limit).map((r) => r.toRecentActivity()).toList();
    });
  }

  Future<_PatientScreeningData> _fetchPatientWithLatestScreening(
    QueryDocumentSnapshot<Map<String, dynamic>> patientDoc,
  ) async {
    final patientId = patientDoc.id;
    final patientData = patientDoc.data();
    final patientName = patientData['name'] ?? 'Unknown';

    final screeningSnap = await _firestore
        .collection('patients')
        .doc(patientId)
        .collection('screenings')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (screeningSnap.docs.isEmpty) {
      // No screening yet
      final createdAt = (patientData['createdAt'] as Timestamp?)?.toDate();
      return _PatientScreeningData(
        patientId: patientId,
        name: patientName,
        status: 'New (Not Screened)',
        statusColor: 0xFF9E9E9E, // Grey
        date: createdAt,
      );
    }

    final data = screeningSnap.docs.first.data();
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

    // Determine status based on screening data
    final statusInfo = _determineStatus(data);

    return _PatientScreeningData(
      patientId: patientId,
      name: patientName,
      status: statusInfo.status,
      statusColor: statusInfo.color,
      date: createdAt,
    );
  }

  _StatusInfo _determineStatus(Map<String, dynamic> data) {
    final status = data['status']?.toString() ?? '';
    final diagnosisStatus = data['diagnosisStatus']?.toString().toLowerCase() ?? '';

    // Priority order for status determination
    if (status == 'Needs Lab Test') {
      return _StatusInfo('Needs Lab Test', 0xFFE53935); // Red
    }

    if (data['referred'] == true) {
      return _StatusInfo('Referred to Facility', 0xFF2697FF); // Blue
    }

    if (diagnosisStatus == 'confirmed') {
      return _StatusInfo('Confirmed TB Case', 0xFFEF476F); // Pink/Red
    }

    if (diagnosisStatus == 'pending') {
      return _StatusInfo('Follow-up Pending', 0xFFFFC857); // Yellow
    }

    if (diagnosisStatus == 'negative' || diagnosisStatus == 'completed') {
      return _StatusInfo('Completed', 0xFF4CAF50); // Green
    }

    // Check AI prediction for flagging
    final aiPrediction = data['aiPrediction'] as Map<String, dynamic>?;
    if (aiPrediction != null) {
      final tbScore = double.tryParse(aiPrediction['TB']?.toString() ?? '0') ?? 0;
      if (tbScore > 0.5) {
        return _StatusInfo('AI Flagged - High Risk', 0xFFFF9800); // Orange
      }
    }

    return _StatusInfo('Screened', 0xFFB0BEC5); // Grey-blue
  }
}

/// Internal helper class for status
class _StatusInfo {
  final String status;
  final int color;
  _StatusInfo(this.status, this.color);
}

/// Internal helper class for patient screening data
class _PatientScreeningData {
  final String patientId;
  final String name;
  final String status;
  final int statusColor;
  final DateTime? date;

  _PatientScreeningData({
    required this.patientId,
    required this.name,
    required this.status,
    required this.statusColor,
    this.date,
  });

  RecentActivity toRecentActivity() {
    return RecentActivity(
      patientId: patientId,
      name: name,
      status: status,
      statusColor: statusColor,
      date: date,
    );
  }
}