import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tbcare_main/features/chw/services/lab_test_service.dart';
import 'package:tbcare_main/features/chw/widgets/chw_back_button.dart';
import 'package:tbcare_main/core/app_constants.dart';

class LabTestScreen extends StatefulWidget {
  const LabTestScreen({super.key});

  @override
  State<LabTestScreen> createState() => _LabTestScreenState();
}

class _LabTestScreenState extends State<LabTestScreen> {
  final LabTestService _service = LabTestService();
  bool _isUploading = false;
  File? _pickedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const ChwBackButton(iconColor: Colors.white),
        title: const Text("Patients Needing Lab Test"),
        backgroundColor: secondaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _service.getPatientsNeedingLabTest(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text("Error loading patients",
                    style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: primaryColor));
          }

          final patients = snapshot.data!;
          if (patients.isEmpty) {
            return const Center(
                child: Text("No patients need lab test",
                    style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: patients.length,
            itemBuilder: (context, i) {
              final patient = patients[i];
              return Card(
                color: secondaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(patient['name'] ?? 'Unnamed',
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    "Diagnosis: ${patient['diagnosisStatus'] ?? 'N/A'}\nPhone: ${patient['phone'] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    onPressed: () => _showUploadDialog(
                      patient['patientId'] ?? "",
                      patient['screeningId'] ?? "", // ✅ Pass screeningId
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showUploadDialog(String patientId, String screeningId) async {
    final testNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: const Text("Upload Lab Test",
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: testNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Test Name",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () async {
                final file = await _service.pickFile(); // ✅ Fixed
                if (file != null) {
                  setState(() => _pickedFile = file);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("File selected")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No file selected")));
                }
              },
              child: const Text("Pick File"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white70))),
          TextButton(
            onPressed: () async {
              if (testNameController.text.isEmpty || _pickedFile == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Enter test name & pick a file")));
                return;
              }

              setState(() => _isUploading = true);
              Navigator.pop(context);

              try {
                // ✅ Upload to Cloudinary
                final url = await _service.uploadToCloudinary(_pickedFile!);

                // ✅ Save record in Firestore
                await _service.saveLabTest(
                  patientId: patientId,
                  screeningId: screeningId, // ✅ Added
                  testName: testNameController.text,
                  fileUrl: url,
                );

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Lab Test uploaded successfully")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")));
              } finally {
                setState(() => _isUploading = false);
              }
            },
            child: const Text("Upload",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
