import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:record/record.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tbcare_main/features/chw/models/patient_screening_model.dart';

class ScreeningService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AudioRecorder _recorder = AudioRecorder();

  String get chwId => FirebaseAuth.instance.currentUser!.uid;

  bool isRecording = false;
  String? _lastRecordedFilePath;

  /// 🎤 Start/Stop recording with single toggle
  Future<String?> recordCough() async {
    try {
      if (!isRecording) {
        final micStatus = await Permission.microphone.request();
        if (!micStatus.isGranted) throw Exception(
            "Microphone permission not granted");

        final hasPermission = await _recorder.hasPermission();
        if (!hasPermission) throw Exception("No recorder permission");

        final dir = await getApplicationDocumentsDirectory();
        final path = "${dir.path}/cough_${DateTime
            .now()
            .millisecondsSinceEpoch}.m4a";

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        isRecording = true;
        _lastRecordedFilePath = path;
        return null;
      } else {
        final path = await _recorder.stop();
        isRecording = false;
        _lastRecordedFilePath = path;
        return path;
      }
    } catch (e) {
      print("❌ Recording error: $e");
      rethrow;
    }
  }

  /// ☁️ Upload cough to Cloudinary
  Future<String?> uploadCough(String patientId) async {
    try {
      if (_lastRecordedFilePath == null) return null;

      final file = File(_lastRecordedFilePath!);
      if (!await file.exists()) return null;

      const cloudName = "de1oz7jbg";
      const uploadPreset = "unsigned_preset";

      final url = Uri.parse(
          "https://api.cloudinary.com/v1_1/$cloudName/auto/upload");

      final request = http.MultipartRequest("POST", url)
        ..fields["upload_preset"] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath("file", file.path));

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(resBody);
        print("✅ Cough uploaded: ${data["secure_url"]}");
        return data["secure_url"];
      } else {
        print("❌ Cough upload failed: $resBody");
        return null;
      }
    } catch (e) {
      print("❌ Upload failed: $e");
      return null;
    }
  }

  /// ☁️ Upload X-ray (image) to Cloudinary
  Future<String?> pickAndUploadXray() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return null;

      File file = File(pickedFile.path);

      // 🔹 Replace with your Cloudinary details
      const cloudName = "de1oz7jbg";
      const uploadPreset = "upload_x-ray";
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath("file", file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final jsonRes = json.decode(resStr);
        return jsonRes["secure_url"];
      } else {
        throw Exception("Cloudinary upload failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ X-ray upload error: $e");
      return null;
    }
  }
  /// 📤 Submit screening with optional X-ray
  Future<void> submitScreening(
  Screening screening, {
  File? xrayFile, // accept raw File instead of pre-uploaded URL
}) async {
  try {
    print("▶️ Starting submission for patient: ${screening.patientId}");

    // 🔹 Upload cough audio (mandatory)
    final coughUrl = await uploadCough(screening.patientId);
    if (coughUrl == null) {
      throw Exception("❌ Cloudinary cough upload failed");
    }

    // 🔹 Upload X-ray if provided (optional)
    String xrayUrl = "";
    if (xrayFile != null) {
      try {
        // You can reuse your pickAndUploadXray logic here
        const cloudName = "de1oz7jbg";
        const uploadPreset = "upload_x-ray";
        final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

        final request = http.MultipartRequest("POST", url)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(await http.MultipartFile.fromPath("file", xrayFile.path));

        final response = await request.send();
        if (response.statusCode == 200) {
          final resStr = await response.stream.bytesToString();
          final jsonRes = json.decode(resStr);
          xrayUrl = jsonRes["secure_url"] ?? "";
          print("✅ X-ray uploaded: $xrayUrl");
        } else {
          throw Exception("Cloudinary X-ray upload failed: ${response.statusCode}");
        }
      } catch (e) {
        print("⚠️ X-ray upload skipped due to error: $e");
      }
    }

    // 🔹 Check if a screening already exists today for this CHW + patient
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final existing = await _db
        .collection("screenings")
        .where("patientId", isEqualTo: screening.patientId)
        .where("chwId", isEqualTo: chwId)
        .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    final data = screening.toMap()
      ..['coughAudioPath'] = coughUrl
      ..['media'] = {
        'coughUrl': coughUrl,
        'xrayUrl': xrayUrl,
      };

    DocumentReference screeningRef;
    if (existing.docs.isNotEmpty) {
      print("🔄 Updating existing screening");
      screeningRef = existing.docs.first.reference;
      await screeningRef.update(data);
    } else {
      print("➕ Creating new screening document");
      screeningRef = await _db.collection('screenings').add(data);
    }

    // 🔹 Generate Dummy AI Result
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final tbProb = (random / 100).toStringAsFixed(2);
    final normalProb = (1 - double.parse(tbProb)).toStringAsFixed(2);

    final aiPrediction = {
      "Normal": normalProb,
      "TB": tbProb,
    };

    final followUpNeeded = double.parse(tbProb) > 0.5;

    await screeningRef.update({
      'aiPrediction': aiPrediction,
      'followUpNeeded': followUpNeeded,
      'status': "completed",
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print("✅ Screening submitted with dummy AI result: $aiPrediction");
  } catch (e, st) {
    print("❌ Screening submission failed: $e");
    print(st);
    rethrow;
  }
}


// Dispose method should be **outside** submitScreening
  void dispose() {
    _recorder.dispose();
  }
}
