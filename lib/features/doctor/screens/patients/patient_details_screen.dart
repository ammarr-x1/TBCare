import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'package:tbcare_main/features/doctor/models/patient_model.dart';
import 'package:tbcare_main/features/doctor/models/screening_model.dart';
import 'package:tbcare_main/features/doctor/services/screening_service.dart';
import '../assessments/diagnose_screen.dart';
import 'package:tbcare_main/core/utils/string_extensions.dart';

class PatientDetailScreen extends StatefulWidget {
  final PatientModel patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  List<ScreeningModel> screenings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScreenings();
  }

  Future<void> _loadScreenings() async {
    try {
      final data = await ScreeningService.fetchScreeningsForPatient(
        widget.patient.uid,
      );
      setState(() {
        screenings = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading screenings: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          "Screenings - ${widget.patient.name}",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadScreenings,
            padding: EdgeInsets.fromLTRB(0, 0, defaultPadding, 0),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25,defaultPadding,25,defaultPadding),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : screenings.isEmpty
            ? Center(
                child: Text(
                  "No screenings found",
                  style: TextStyle(
                    color: secondaryColor.withOpacity(0.7),
                    fontSize: bodySize,
                  ),
                ),
              )
            : ListView.separated(
                itemCount: screenings.length,
                separatorBuilder: (_, __) => SizedBox(height: defaultPadding),
                itemBuilder: (context, index) {
                  final screening = screenings[index];
                  return _buildScreeningCard(screening);
                },
              ),
      ),
    );
  }

  Widget _buildScreeningCard(ScreeningModel screening) {
    // 1. Diagnosis Logic (User Requirement: Use patient's diagnosisStatus if available)
    // We check the specific screening first. If it's pending, we check if the PATIENT has a status 
    // that might apply to this screening (assuming it's the latest one).
    // Complexity: Screening diagnosis is specific to that screening. Patient diagnosis might be general.
    // However, the user explicitly asked to use the patient's status instead of "pending".
    
    String displayStatus = "Pending";
    bool isDiagnosed = false;

    if (screening.finalDiagnosis != null && screening.finalDiagnosis!.isNotEmpty) {
      displayStatus = screening.finalDiagnosis!;
      isDiagnosed = true;
    } else {
      // Fallback to patient status if this is likely the relevant screening (e.g. latest)
      // Or simply follow user instruction to use it if available.
      if (widget.patient.diagnosisStatus.isNotEmpty && widget.patient.diagnosisStatus.toLowerCase() != 'pending') {
         displayStatus = widget.patient.diagnosisStatus;
         isDiagnosed = true;
      }
    }

    // Colors
    final statusColor = isDiagnosed 
        ? (displayStatus.toLowerCase().contains("tb") && !displayStatus.toLowerCase().contains("not") ? errorColor : successColor) 
        : warningColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.calendar_today_rounded, color: statusColor, size: 20),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          screening.date.toLocal().toString().split(' ')[0],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: secondaryColor,
                          ),
                        ),
                        Text(
                          "Screening Date",
                          style: TextStyle(
                            color: secondaryColor.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    displayStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Symptoms
                if (screening.symptoms.entries.where((e) => e.value == true).isNotEmpty) ...[
                  Text(
                    "REPORTED SYMPTOMS",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: screening.symptoms.entries
                        .where((e) => e.value == true)
                        .map((e) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: secondaryColor.withOpacity(0.05)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline, size: 16, color: primaryColor.withOpacity(0.6)),
                                  const SizedBox(width: 8),
                                  Text(
                                    e.key,
                                    style: TextStyle(
                                      color: secondaryColor.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: secondaryColor.withOpacity(0.05)),
                  const SizedBox(height: 24),
                ],

                // AI Analysis
                Text(
                  "AI ANALYSIS",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor.withOpacity(0.05), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryColor.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: screening.aiPrediction.entries.map((e) {
                      final key = e.key;
                      final value = e.value;
                      
                      String displayValue = value.toString();
                      if (key == 'confidence' && value is num) {
                        displayValue = "${(value * 100).toStringAsFixed(1)}%";
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              key.capitalize(),
                              style: TextStyle(
                                color: secondaryColor.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              displayValue,
                              style: const TextStyle(
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}