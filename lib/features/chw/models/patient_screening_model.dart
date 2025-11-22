import 'package:cloud_firestore/cloud_firestore.dart';

class Screening {
  String? id;
  String patientId;
  String patientName;
  String chwId;
  List<String> symptoms;
  String coughAudioPath;
  String aiPrediction;
  Map<String, String> media;
  bool followUpNeeded;
  String followUpStatus;
  bool referred;
  Timestamp timestamp;
  Timestamp? updatedAt;

  Screening({
    this.id,
    required this.patientId,
    required this.patientName,
    required this.chwId,
    required this.symptoms,
    required this.coughAudioPath,
    required this.aiPrediction,
    required this.media,
    required this.followUpNeeded,
    required this.followUpStatus,
    required this.referred,
    required this.timestamp,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'chwId': chwId,
      'symptoms': symptoms.isEmpty ? ["No symptoms"] : symptoms,
      'coughAudioPath': coughAudioPath,
      'aiPrediction': aiPrediction,
      'media': media,
      'followUpNeeded': followUpNeeded,
      'followUpStatus': followUpStatus,
      'referred': referred,
      'timestamp': timestamp,
      'updatedAt': updatedAt,
    };
  }

  factory Screening.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Screening(
      id: doc.id,
      patientId: data['patientId'],
      patientName: data['patientName'],
      chwId: data['chwId'],
      symptoms: List<String>.from(data['symptoms']),
      coughAudioPath: data['coughAudioPath'],
      aiPrediction: data['aiPrediction'],
      media: Map<String, String>.from(data['media'] ?? {'coughUrl': '', 'xrayUrl': ''}),
      followUpNeeded: data['followUpNeeded'],
      followUpStatus: data['followUpStatus'],
      referred: data['referred'],
      timestamp: data['timestamp'],
      updatedAt: data['updatedAt'],
    );
  }

  /// 🆕 Added copyWith
  Screening copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? chwId,
    List<String>? symptoms,
    String? coughAudioPath,
    String? aiPrediction,
    Map<String, String>? media, // optional media map
    bool? followUpNeeded,
    String? followUpStatus,
    bool? referred,
    Timestamp? timestamp,
    Timestamp? updatedAt,
  }) {
    return Screening(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      chwId: chwId ?? this.chwId,
      symptoms: symptoms ?? this.symptoms,
      coughAudioPath: coughAudioPath ?? this.coughAudioPath,
      aiPrediction: aiPrediction ?? this.aiPrediction,
      media: media ?? this.media,
      followUpNeeded: followUpNeeded ?? this.followUpNeeded,
      followUpStatus: followUpStatus ?? this.followUpStatus,
      referred: referred ?? this.referred,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

}
