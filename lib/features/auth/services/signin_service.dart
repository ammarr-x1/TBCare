import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tbcare_main/features/auth/models/signin_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Email/Password Sign-In
  Future<UserModel?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = cred.user;
    if (user == null || !user.emailVerified) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!, user.uid);
  }

  /// Google Sign-In (works for both Web & Mobile)
  Future<UserModel?> signInWithGoogle({required Future<String?> Function() onRolePrompt}) async {
    UserCredential userCred;

    if (kIsWeb) {
      // ✅ Web flow: use Firebase popup auth
      final googleProvider = GoogleAuthProvider();
      userCred = await _auth.signInWithPopup(googleProvider);
    } else {
      // ✅ Mobile flow: use GoogleSignIn package
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // canceled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userCred = await _auth.signInWithCredential(credential);
    }

    final user = userCred.user;
    if (user == null) return null;

    final docRef = _db.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      // 🔥 First time sign-in → ask for role
      final role = await onRolePrompt();
      if (role == null) {
        await _auth.signOut();
        return null;
      }
      await docRef.set({
        "uid": user.uid,
        "name": user.displayName ?? "",
        "email": user.email ?? "",
        "role": role,
        "verified": true,
        "createdAt": FieldValue.serverTimestamp(),
      });
      return UserModel(
        uid: user.uid,
        name: user.displayName ?? "",
        email: user.email ?? "",
        role: role,
        verified: true,
      );
    } else {
      return UserModel.fromMap(doc.data()!, user.uid);
    }
  }

  /// Sign-Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
