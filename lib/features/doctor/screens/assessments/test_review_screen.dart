import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'package:tbcare_main/features/doctor/models/ai_case_model.dart';
import 'package:tbcare_main/features/doctor/models/lab_test_model.dart';
import 'package:tbcare_main/features/doctor/services/diagnosis_service.dart';
import 'package:tbcare_main/features/doctor/services/lab_test_service.dart';

class TestReviewScreen extends StatefulWidget {
  final AiCaseModel caseData;

  const TestReviewScreen({super.key, required this.caseData});

  @override
  State<TestReviewScreen> createState() => _TestReviewScreenState();
}

class _TestReviewScreenState extends State<TestReviewScreen> {
  final TextEditingController _remarksController = TextEditingController();
  String? _finalDiagnosis;
  List<LabTestModel> labTests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLabTests();
  }

  Future<void> loadLabTests() async {
    try {
      final tests = await LabTestService.getLabTests(
        patientId: widget.caseData.patientId,
        screeningId: widget.caseData.screeningId,
      );

      if (!mounted) return;

      setState(() {
        labTests = tests;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading tests: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> saveFinalDiagnosis() async {
    if (_finalDiagnosis == null || _finalDiagnosis!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a final diagnosis")),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Authentication error. Please sign in again."),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    try {
      await DiagnosisService.updateFinalVerdict(
        patientId: widget.caseData.patientId,
        screeningId: widget.caseData.screeningId,
        doctorId: currentUser.uid, 
        status: _finalDiagnosis!,
        notes: _remarksController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Diagnosis updated"),
          backgroundColor: successColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Error updating final verdict: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text("Failed to update diagnosis"),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Review Lab Tests",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(defaultPadding),
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : SingleChildScrollView(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lab Test Results",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (labTests.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: secondaryColor.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.science_outlined,
                              size: 48,
                              color: secondaryColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "No tests uploaded yet",
                              style: TextStyle(
                                color: secondaryColor.withOpacity(0.7),
                                fontSize: bodySize,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...labTests.map(
                        (test) => Card(
                          color: Colors.white,
                          elevation: 2,
                          shadowColor: Colors.black.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.insert_drive_file,
                                color: accentColor,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              test.testName,
                              style: TextStyle(
                                color: secondaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: bodySize,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(test.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _getStatusColor(test.status).withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    test.status,
                                    style: TextStyle(
                                      color: _getStatusColor(test.status),
                                      fontSize: captionSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.download, color: primaryColor),
                              onPressed: () {
                                // Optional: open PDF/image preview if implemented
                              },
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: secondaryColor.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.medical_information, color: primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                "Final Diagnosis",
                                style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Diagnosis",
                        labelStyle: TextStyle(color: secondaryColor.withOpacity(0.7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          borderSide: BorderSide(color: secondaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          borderSide: BorderSide(color: secondaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                      dropdownColor: Colors.white,
                      style: TextStyle(color: secondaryColor),
                      value: _finalDiagnosis,
                      items: ['TB', 'Not TB']
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: secondaryColor),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _finalDiagnosis = val),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _remarksController,
                      maxLines: 3,
                      style: TextStyle(color: secondaryColor),
                      decoration: InputDecoration(
                        labelText: "Remarks",
                        labelStyle: TextStyle(color: secondaryColor.withOpacity(0.7)),
                        hintText: "Add notes, prescription, etc.",
                        hintStyle: TextStyle(color: secondaryColor.withOpacity(0.5)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          borderSide: BorderSide(color: secondaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          borderSide: BorderSide(color: secondaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(defaultRadius),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: secondaryColor,
                            side: BorderSide(color: secondaryColor.withOpacity(0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(defaultRadius),
                            ),
                          ),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: saveFinalDiagnosis,
                          icon: const Icon(Icons.check_circle),
                          label: const Text("Confirm Diagnosis"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(defaultRadius),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'normal':
        return successColor;
      case 'pending':
      case 'processing':
        return warningColor;
      case 'abnormal':
      case 'failed':
        return errorColor;
      default:
        return accentColor;
    }
  }
}