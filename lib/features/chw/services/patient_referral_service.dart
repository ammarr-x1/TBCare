import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tbcare_main/features/chw/models/patient_referral_model.dart';
import 'dart:developer' as dev;

class ReferralService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  /// Stream all referrals
  Stream<List<Referral>> getAllReferrals() {
    dev.log("Fetching all referrals from Firestore", name: "ReferralService");
    return _fire
        .collection('referrals')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) {
      dev.log("Retrieved ${snap.docs.length} referrals",
          name: "ReferralService");
      return snap.docs.map((doc) => Referral.fromDoc(doc)).toList();
    });
  }

  /// Update referral status
  Future<void> updateReferralStatus(String id, String newStatus) async {
    dev.log("Updating referral $id to status $newStatus",
        name: "ReferralService");
    await _fire.collection('referrals').doc(id).update({'status': newStatus});
  }
}
