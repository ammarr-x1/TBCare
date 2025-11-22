import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'package:tbcare_main/features/doctor/models/patient_model.dart';
import 'package:tbcare_main/features/doctor/models/screening_model.dart';
import 'package:tbcare_main/features/doctor/services/diagnosis_service.dart';

class DiagnoseScreen extends StatefulWidget {
  final PatientModel patient;
  final ScreeningModel screening;

  const DiagnoseScreen({
    super.key,
    required this.patient,
    required this.screening,
  });

  @override
  State<DiagnoseScreen> createState() => _DiagnoseScreenState();
}

class _DiagnoseScreenState extends State<DiagnoseScreen> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _testController = TextEditingController();
  String? _selectedDiagnosis;
  bool _showTestField = false;
  bool _isLoading = false;

  final List<String> diagnosisOptions = ['TB', 'Not TB', 'Needs Lab Test'];

  void _onDiagnosisChanged(String? value) {
    setState(() {
      _selectedDiagnosis = value;
      _showTestField = value == 'Needs Lab Test';
    });
  }

  Future<void> _submitDiagnosis() async {
    if (_selectedDiagnosis == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select a diagnosis.")));
      return;
    }

    if (_showTestField && _testController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please specify the lab test required.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await DiagnosisService.saveDiagnosisAndLabTest(
        patientId: widget.patient.uid,
        screeningId: widget.screening.screeningId,
        doctorId: FirebaseAuth.instance.currentUser!.uid,
        diagnosis: _selectedDiagnosis!,
        notes: _notesController.text.trim(),
        requestedTest: _showTestField ? _testController.text.trim() : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Diagnosis saved successfully"),
          backgroundColor: successColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Error saving diagnosis: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text("Failed to save diagnosis"),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Diagnose Case"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Diagnosis", 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: secondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Diagnosis",
                labelStyle: TextStyle(color: secondaryColor.withOpacity(0.7)),
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
              dropdownColor: Colors.white,
              style: TextStyle(color: secondaryColor),
              value: _selectedDiagnosis,
              items: diagnosisOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option, style: TextStyle(color: secondaryColor)),
                );
              }).toList(),
              onChanged: _onDiagnosisChanged,
            ),
            const SizedBox(height: 16),
            if (_showTestField)
              TextField(
                controller: _testController,
                style: TextStyle(color: secondaryColor),
                decoration: InputDecoration(
                  labelText: "Requested Test",
                  labelStyle: TextStyle(color: secondaryColor.withOpacity(0.7)),
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
                  hintText: "e.g., Sputum, CBC, etc.",
                  hintStyle: TextStyle(color: secondaryColor.withOpacity(0.5)),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: TextStyle(color: secondaryColor),
              decoration: InputDecoration(
                labelText: "Notes (Optional)",
                labelStyle: TextStyle(color: secondaryColor.withOpacity(0.7)),
                hintText: "Additional comments, prescription, etc.",
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
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitDiagnosis,
                icon: Icon(Icons.save),
                label: Text("Submit Diagnosis"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}