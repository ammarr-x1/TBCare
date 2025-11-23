import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tbcare_main/features/auth/models/signup_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Sign up user
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    String status = "Active", // add this
    bool flagged = false, // add this
  }) async {
    try {
      // Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user!.sendEmailVerification();
      final uid = userCredential.user!.uid;

      // Create UserModel
      UserModel user = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: role,
        verified: true,
        status: status, // use parameter
        flagged: flagged, // use parameter
      );

      // Save to Firestore
      await _db.collection('users').doc(uid).set(user.toMap());

      // CHW special collection
      if (role == "CHW") {
        await _db.collection('chws').doc(uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'lastActivity': null,
          'status': status,
          'flagged': flagged,
        });
      }

      if (role == "Doctor") {
        await _db.collection('doctors').doc(uid).set({
          'uid': uid,
          'name': name,
          'email': email,
          'phone': '',
          'specialization': '',
          'confirmedTBCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'patientsReviewed': [],
          'totalDiagnosisMade': 0,
          'totalFinalVerdicts': 0,
          'totalPatientsReviewed': 0,
          'totalRecommendationGiven': 0,
          'totalTestsRequested': 0,
          'status': status,
          'flagged': flagged,
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } on FirebaseException catch (e) {
      return e.message;
    } catch (e) {
      return 'Unknown error: $e';
    }
  }
}
