import 'package:flutter/material.dart';

class LabTestService {
  // Neutralized to prevent build errors while focusing on Doctor module
  Stream<List<Map<String, dynamic>>> getPatientsNeedingLabTest() async* {
    yield [];
  }

  Future<void> saveLabTest({
    required String patientId,
    required String screeningId,
    required String testName,
    required String fileUrl,
  }) async {}

  Stream<List<dynamic>> fetchLabTests(String patientId, String screeningId) async* {
    yield [];
  }

  Future<dynamic> pickFile() async => null;
  Future<String> uploadToCloudinary(dynamic file) async => "";
}
