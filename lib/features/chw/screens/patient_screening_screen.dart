import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:tbcare_main/features/chw/models/patient_screening_model.dart';
import 'package:tbcare_main/features/chw/services/patient_screening_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tbcare_main/features/chw/widgets/chw_back_button.dart';
import 'package:tbcare_main/core/app_constants.dart';

class ScreeningScreen extends StatefulWidget {
  const ScreeningScreen({super.key});

  @override
  State<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends State<ScreeningScreen> {
  final ScreeningService service = ScreeningService();
  final List<String> symptoms = [
    "Persistent cough",
    "Fever",
    "Weight loss",
    "Night sweats",
    "Chest pain",
    "Fatigue or weakness",
    "Blood in cough",
    "Shortness of breath",
    "Loss of appetite",
    "Swollen lymph nodes"
  ];

  List<String> selectedSymptoms = [];
  String? selectedPatientId;
  String? selectedPatientName;
  String? coughAudioUrl;
  File? xrayFile;

  void toggleSymptom(String symptom) {
    setState(() {
      if (selectedSymptoms.contains(symptom)) {
        selectedSymptoms.remove(symptom);
      } else {
        selectedSymptoms.add(symptom);
      }
    });
  }

  Future<void> handleRecord() async {
    try {
      final path = await service.recordCough();

      if (service.isRecording) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🎤 Recording started... speak now")),
        );
      } else if (path != null) {
        setState(() {
          coughAudioUrl = path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recording stopped")),
        );
      }
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  // 🔹 Pick optional X-ray PDF using file_selector
  Future<void> pickXrayFile() async {
    try {
      final status = await Permission.storage.request(); // For Android 10 and below
      if (!status.isGranted &&
          await Permission.manageExternalStorage.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission is required")),
        );
        return;
      }

      final typeGroup = XTypeGroup(label: 'documents', extensions: ['pdf']);
      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file != null) {
        setState(() => xrayFile = File(file.path));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ X-ray selected: ${file.name}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to pick file: $e")),
      );
    }
  }

  Future<void> handleSubmit() async {
    if (selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please select a patient first")),
      );
      return;
    }

    if (coughAudioUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please record cough before submitting")),
      );
      return;
    }

    final screening = Screening(
      patientId: selectedPatientId!,
      patientName: selectedPatientName ?? "Unnamed",
      chwId: service.chwId,
      symptoms: selectedSymptoms,
      coughAudioPath: coughAudioUrl ?? "",
      media: {
        'coughUrl': coughAudioUrl ?? '',
        'xrayUrl': '',
      },
      aiPrediction: "pending",
      followUpNeeded: false,
      followUpStatus: "pending_ai",
      referred: false,
      timestamp: Timestamp.now(),
    );

    await service.submitScreening(screening, xrayFile: xrayFile);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Screening submitted successfully!")),
    );

    setState(() {
      selectedSymptoms.clear();
      coughAudioUrl = null;
      selectedPatientId = null;
      xrayFile = null;
    });
  }

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const ChwBackButton(iconColor: bgColor),
        title: const Text(
          "Cough Screening",
          style: TextStyle(color: bgColor),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: bgColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Start TB Screening",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor)),
          const SizedBox(height: defaultPadding),

          // Patient selection
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("chws")
                .doc(service.chwId)
                .collection("assigned_patients")
                .snapshots(),
            builder: (context, patientSnap) {
              if (!patientSnap.hasData) {
                return const CircularProgressIndicator();
              }

              final assignedPatients = patientSnap.data!.docs;

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("screenings")
                    .where("chwId", isEqualTo: service.chwId)
                    .get(),
                builder: (context, screeningSnap) {
                  if (!screeningSnap.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final screenedIds = screeningSnap.data!.docs
                      .map((doc) => doc['patientId'] as String)
                      .toSet();

                  final availablePatients = assignedPatients
                      .where((p) => !screenedIds.contains(p.id))
                      .toList();

                  if (availablePatients.isEmpty) {
                    return const Text(
                      "🎉 All patients screened!",
                      style: TextStyle(color: Colors.white70),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    dropdownColor: primaryColor,
                    value: availablePatients.any((p) => p.id == selectedPatientId)
                        ? selectedPatientId
                        : null,
                    hint: const Text("Select Patient",
                        style: TextStyle(color: secondaryColor)),
                    items: availablePatients.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(
                          p['name'] ?? "Unnamed",
                          style: const TextStyle(color: bgColor),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      final patientDoc =
                          availablePatients.firstWhere((p) => p.id == val);
                      setState(() {
                        selectedPatientId = val;
                        selectedPatientName = patientDoc['name'];
                      });
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // Record cough
          ElevatedButton.icon(
            onPressed: handleRecord,
            icon: Icon(service.isRecording ? Icons.stop : Icons.mic),
            label: Text(service.isRecording ? "Stop Recording" : "Record Cough"),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  service.isRecording ? Colors.red : primaryColor,
            ),
          ),
          const SizedBox(height: 20),

          // Select symptoms
          const Text("Select symptoms:",
              style: TextStyle(
                  color: secondaryColor, fontWeight: FontWeight.bold)),
          Card(
            color: secondaryColor.withOpacity(0.4),
            child: Column(
              children: symptoms
                  .map((s) => CheckboxListTile(
                        title: Text(s,
                            style: const TextStyle(color: Colors.white)),
                        value: selectedSymptoms.contains(s),
                        onChanged: (bool? checked) => toggleSymptom(s),
                        activeColor: primaryColor,
                        checkColor: Colors.white,
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: 10),

          // Upload optional X-ray PDF
          ElevatedButton.icon(
            onPressed: pickXrayFile,
            icon: const Icon(Icons.upload_file),
            label: Text(
                xrayFile == null ? "Upload X-ray (optional)" : "X-ray Selected"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 10),

          // Submit
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: handleSubmit,
              icon: const Icon(Icons.send),
              label: const Text("Submit Screening"),
            ),
          )
        ],
      ),
    );
  }
}
