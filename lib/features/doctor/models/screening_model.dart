import 'package:cloud_firestore/cloud_firestore.dart';

class ScreeningModel {
  final String screeningId;
  final DateTime date;
  final String submittedBy;
  final Map<String, dynamic> symptoms;
  final Map<String, dynamic> aiPrediction;
  final String? finalDiagnosis;
  final String status;
  final String? diagnosedBy;
  final String mediaType; // "xray" or "cough"
  final String mediaUrl;

  ScreeningModel({
    required this.screeningId,
    required this.date,
    required this.submittedBy,
    required this.symptoms,
    required this.aiPrediction,
    required this.status,
    required this.mediaType,
    required this.mediaUrl,
    this.finalDiagnosis,
    this.diagnosedBy,
  });

  factory ScreeningModel.fromMap(Map<String, dynamic> data, String id) {
    return ScreeningModel(
      screeningId: data['screeningId'] ?? id,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      submittedBy: data['submittedBy']?.toString() ?? '',
      symptoms: Map<String, dynamic>.from(data['symptoms'] ?? {}),
      aiPrediction: Map<String, dynamic>.from(data['aiPrediction'] ?? {}),
      finalDiagnosis: data['finalDiagnosis'],
      diagnosedBy: data['diagnosedBy'],
      status: data['status'] ?? 'Pending Review',
      mediaType: data['mediaType'] ?? 'cough',
      mediaUrl: data['mediaUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'screeningId': screeningId,
      'date': Timestamp.fromDate(date),
      'submittedBy': submittedBy,
      'symptoms': symptoms,
      'aiPrediction': aiPrediction,
      'finalDiagnosis': finalDiagnosis,
      'diagnosedBy': diagnosedBy,
      'status': status,
      'mediaType': mediaType,
      'mediaUrl': mediaUrl,
    };
  }
}
