import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recent_cases.dart';

class RecentCasesService {
  static final _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _patientsRef =>
      _firestore.collection('patients');

  /// Fetch the most recent cases across patients
  static Future<List<RecentCase>> fetchRecentCases({int limit = 5}) async {
    try {
      final patientsSnap = await _patientsRef.get();
      final List<RecentCase> cases = [];

      for (var patientDoc in patientsSnap.docs) {
        final screeningsSnap = await patientDoc.reference
            .collection('screenings')
            .orderBy('date', descending: true)
            .limit(1)
            .get();

        if (screeningsSnap.docs.isEmpty) continue;

        final screeningDoc = screeningsSnap.docs.first;
        cases.add(
          RecentCase.fromFirestore(
            patientDoc.data(),
            screeningDoc.data(),
            patientDoc.id,
            screeningDoc.id,
          ),
        );
      }

      cases.sort((a, b) => b.date.compareTo(a.date));
      return cases.take(limit).toList();
    } catch (e) {
      print("❌ Error fetching recent cases: $e");
      rethrow;
    }
  }
}
