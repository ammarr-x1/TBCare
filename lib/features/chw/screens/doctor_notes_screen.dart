import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'package:tbcare_main/features/chw/widgets/chw_back_button.dart';

class DoctorNotesScreen extends StatelessWidget {
  final String patientId;
  final String screeningId;
  final String patientName;

  const DoctorNotesScreen({
    super.key,
    required this.patientId,
    required this.screeningId,
    required this.patientName,
  });

  Future<Map<String, dynamic>> _fetchNotes() async {
    final firestore = FirebaseFirestore.instance;

    final screeningRef = firestore
        .collection("patients")
        .doc(patientId)
        .collection("screenings")
        .doc(screeningId);

    final docSnap = await screeningRef.get();

    final diagnosisSnap = await screeningRef.collection("diagnosis").get();
    final recSnap = await screeningRef.collection("recommendations").get();
    final labSnap = await screeningRef.collection("labTests").get();

    return {
      "screening": docSnap.data() ?? {},
      "diagnosis": diagnosisSnap.docs.map((d) => d.data()).toList(),
      "recommendations": recSnap.docs.map((d) => d.data()).toList(),
      "labTests": labSnap.docs.map((d) => d.data()).toList(),
    };
  }

  Widget _buildMapSection(String title, Map<String, dynamic> map) {
    if (map.isEmpty) {
      return Text("No $title available",
          style: const TextStyle(color: Colors.white70));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...map.entries.map((e) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${e.key}: ${e.value}",
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildListSection(String title, List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Text("No $title added",
          style: const TextStyle(color: Colors.white70));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...items.map((item) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.entries.map((e) => "${e.key}: ${e.value}").join("\n"),
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const ChwBackButton(iconColor: Colors.white),
        title: Text(
          "$patientName - Doctor Notes",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: secondaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchNotes(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                "Error: ${snap.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snap.data ?? {};
          final screening = (data["screening"] as Map<String, dynamic>);

          // Safe type conversion for map fields
          Map<String, dynamic> safeMap(dynamic value) {
            if (value is Map) {
              return Map<String, dynamic>.from(value);
            }
            return {"value": value?.toString() ?? ""};
          }

          // Safe type conversion for list of maps
          List<Map<String, dynamic>> safeList(dynamic value) {
            if (value is List) {
              return value.map<Map<String, dynamic>>((e) {
                if (e is Map) {
                  return Map<String, dynamic>.from(e);
                }
                return {"value": e.toString()};
              }).toList();
            }
            return [];
          }

          final diagnosis = safeList(data["diagnosis"]);
          final recs = safeList(data["recommendations"]);
          final labs = safeList(data["labTests"]);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMapSection("AI Prediction",
                    safeMap(screening["aiPrediction"])),
                _buildMapSection("Symptoms", safeMap(screening["symptoms"])),
                _buildMapSection("Media", safeMap(screening["media"])),
                _buildMapSection("Other Info", {
                  "Final Diagnosis": screening["finalDiagnosis"] ?? "",
                  "Status": screening["status"] ?? "",
                  "Diagnosed By": screening["diagnosedBy"] ?? "",
                  "Cough Audio": screening["coughAudioPath"] ?? "",
                  "Date": screening["date"]?.toString() ?? "",
                }),
                const SizedBox(height: 16),
                _buildListSection("Diagnosis Collection", diagnosis),
                _buildListSection("Recommendations Collection", recs),
                _buildListSection("Lab Tests Collection", labs),
              ],
            ),
          );
        },
      ),
    );
  }
}
