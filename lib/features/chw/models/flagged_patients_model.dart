import 'package:cloud_firestore/cloud_firestore.dart';

class Screening {
  final String id;
  final String patientId;
  final String patientName;
  final dynamic aiPrediction;
  final List<String> symptoms;
  final String? coughAudioPath;
  final DateTime? timestamp;
  final Map<String, String>? media;
  final String followUpStatus;
  final bool followUpNeeded;

  Screening({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.aiPrediction,
    required this.symptoms,
    this.coughAudioPath,
    this.timestamp,
    this.media,
    required this.followUpStatus,
    required this.followUpNeeded,
  });

  factory Screening.fromMap(String id, Map<String, dynamic> data) {
    return Screening(
      id: id,
      patientId: data['patientId'] ?? id,
      patientName: data['patientName'] ?? "Unknown",
      aiPrediction: data['aiPrediction'],
      symptoms: List<String>.from(data['symptoms'] ?? []),
      coughAudioPath: data['coughAudioPath'],
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
      media: data['media'] != null
          ? Map<String, String>.from(data['media'])
          : null,
      followUpStatus: data['followUpStatus'] ?? "pending",
      followUpNeeded: data['followUpNeeded'] ?? false,
    );
  }
}
