import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/plan_item_model.dart';

class DietExerciseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current logged-in doctor's ID
  static String? get _currentDoctorId => _auth.currentUser?.uid;

  /// Verify patient belongs to logged-in doctor
  static Future<bool> _verifyPatientOwnership(String patientId) async {
    final doctorId = _currentDoctorId;
    if (doctorId == null) return false;

    final patientDoc = await _firestore
        .collection('patients')
        .doc(patientId)
        .get();
    if (!patientDoc.exists) return false;

    return patientDoc.data()?['selectedDoctor'] == doctorId;
  }

  /// -------- DIET PLAN --------

  static Future<Map<String, dynamic>> fetchAllDietPlans(String patientId) async {
    if (patientId.isEmpty) {
      throw Exception('Invalid patient ID');
    }

    final hasAccess = await _verifyPatientOwnership(patientId);
    if (!hasAccess) {
      print("⚠️ Access denied: Patient not assigned to this doctor");
      return {};
    }

    final Map<String, dynamic> plans = {};

    try {
      final snapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('dietPlan')
          .orderBy('createdAt', descending: false)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final itemsRaw = data['items'] as List<dynamic>? ?? [];
        final List<PlanItemModel> items = itemsRaw
            .map((e) => PlanItemModel.fromMap(e as Map<String, dynamic>))
            .toList();

        plans[data['timeOfDay'] ?? ''] = {
          'docId': doc.id,
          'title': data['title'] ?? '',
          'timeOfDay': data['timeOfDay'] ?? '',
          'approvedByDoctor': data['approvedByDoctor'] ?? false,
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          'items': items,
        };
      }
    } catch (e) {
      rethrow;
    }

    return plans;
  }

  static Future<void> addDietItem({
    required String patientId,
    required String planDocId,
    required PlanItemModel item,
  }) async {
    final hasAccess = await _verifyPatientOwnership(patientId);
    if (!hasAccess) {
      print("⚠️ Access denied: Patient not assigned to this doctor");
      return;
    }

    final docRef = _firestore
        .collection('patients')
        .doc(patientId)
        .collection('dietPlan')
        .doc(planDocId);

    await docRef.update({
      'items': FieldValue.arrayUnion([item.toMap()]),
    });
  }

  static Future<void> deleteDietItem({
    required String patientId,
    required String planDocId,
    required PlanItemModel item,
  }) async {
    final hasAccess = await _verifyPatientOwnership(patientId);
    if (!hasAccess) {
      print("⚠️ Access denied: Patient not assigned to this doctor");
      return;
    }

    final docRef = _firestore
        .collection('patients')
        .doc(patientId)
        .collection('dietPlan')
        .doc(planDocId);

    await docRef.update({
      'items': FieldValue.arrayRemove([item.toMap()]),
    });
  }

  static Future<void> approveDietPlan({
    required String patientId,
    required String planDocId,
  }) async {
    final hasAccess = await _verifyPatientOwnership(patientId);
    if (!hasAccess) {
      print("⚠️ Access denied: Patient not assigned to this doctor");
      return;
    }

    await _firestore
        .collection('patients')
        .doc(patientId)
        .collection('dietPlan')
        .doc(planDocId)
        .update({'approvedByDoctor': true});
  }

  /// -------- EXERCISE PLAN --------

  static Future<Map<String, dynamic>?> fetchAllExercisePlans(String patientId) async {
    if (patientId.isEmpty) {
      return null;
    }

    final hasAccess = await _verifyPatientOwnership(patientId);
    if (!hasAccess) {
      print("⚠️ Access denied: Patient not assigned to this doctor");
      return null;
    }

    try {
      final snapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .collection('exercisePlan')
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      final data = doc.data();

      return {
        'docId': doc.id,
        'title': data['title'],
        'timeOfDay': data['timeOfDay'],
        'approvedByDoctor': data['approvedByDoctor'] ?? false,
        'items': (data['items'] as List)
            .map((e) => PlanItemModel.fromMap(e))
            .toList(),
      };
    } catch (e) {
      return null;
    }
  }

  static Future<void> addExerciseItem({
    required String patientId,
    required String planDocId,
    required PlanItemModel item,
  }) async {
    final hasAccess = await _verifyPatientOwnership(patientId);
    if (!hasAccess) {
      print("⚠️ Access denied: Patient not assigned to this doctor");
      return;
    }

    await _firestore
        .collection('patients')
        .doc(patientId)
        .collection('exercisePlan')
        .doc(planDocId)
        .update({
      'items': FieldValue.arrayUnion([item.toMap()]),
    });
  }

  static Future<void> deleteExerciseItem({
    required String patientId,
    required String planDocId,
    required PlanItemModel item,
  }) async {
    final hasAccess = await _verifyPatientOwnership(patientId);
    if (!hasAccess) {
      print("⚠️ Access denied: Patient not assigned to this doctor");
      return;
    }

    await _firestore
        .collection('patients')
        .doc(patientId)
        .collection('exercisePlan')
        .doc(planDocId)
        .update({
      'items': FieldValue.arrayRemove([item.toMap()]),
    });
  }

  static Future<void> approveExercisePlan({
    required String patientId,
    required String planDocId,
  }) async {
    final hasAccess = await _verifyPatientOwnership(patientId);
    if (!hasAccess) {
      print("⚠️ Access denied: Patient not assigned to this doctor");
      return;
    }

    await _firestore
        .collection('patients')
        .doc(patientId)
        .collection('exercisePlan')
        .doc(planDocId)
        .update({'approvedByDoctor': true});
  }
}