import 'package:flutter/material.dart';
import 'package:tbcare_main/core/app_constants.dart';
import 'package:tbcare_main/features/doctor/models/patient_model.dart';
import 'package:tbcare_main/features/doctor/models/screening_model.dart';
import 'package:tbcare_main/features/doctor/services/screening_service.dart';
import '../assessments/diagnose_screen.dart';

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
    final isDiagnosed =
        screening.finalDiagnosis != null &&
        screening.finalDiagnosis!.isNotEmpty;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.08),
      margin: const EdgeInsets.only(bottom: defaultPadding),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      screening.date.toLocal().toString().split(' ')[0],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                        fontSize: bodySize,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDiagnosed ? successColor.withOpacity(0.1) : warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDiagnosed ? successColor.withOpacity(0.3) : warningColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    isDiagnosed ? screening.finalDiagnosis! : "Pending",
                    style: TextStyle(
                      color: isDiagnosed ? successColor : warningColor,
                      fontWeight: FontWeight.w600,
                      fontSize: captionSize,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Symptoms section
            if (screening.symptoms.entries.where((e) => e.value == true).isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.sick, size: 16, color: secondaryColor.withOpacity(0.7)),
                  const SizedBox(width: 6),
                  Text(
                    "Reported Symptoms:",
                    style: TextStyle(
                      color: secondaryColor.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: captionSize,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: screening.symptoms.entries
                    .where((e) => e.value == true)
                    .map(
                      (e) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: warningColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          e.key,
                          style: const TextStyle(
                            color: warningColor,
                            fontSize: captionSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],

            // AI Prediction section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: secondaryColor.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, size: 16, color: accentColor),
                      const SizedBox(width: 6),
                      Text(
                        "AI Analysis:",
                        style: TextStyle(
                          color: secondaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: captionSize,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...screening.aiPrediction.entries.map((e) {
                    final raw = e.value;
                    double? value;

                    // Safely convert to double
                    if (raw is num) {
                      value = raw.toDouble();
                    } else if (raw is String) {
                      value = double.tryParse(raw);
                    }

                    final display = value != null
                        ? "${(value * 100).toStringAsFixed(1)}%"
                        : "N/A";

                    final percentage = value ?? 0.0;
                    Color predictionColor = percentage > 0.7 
                        ? errorColor 
                        : percentage > 0.4 
                            ? warningColor 
                            : successColor;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key,
                            style: TextStyle(
                              color: secondaryColor.withOpacity(0.8),
                              fontSize: captionSize,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: predictionColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              display,
                              style: TextStyle(
                                color: predictionColor,
                                fontWeight: FontWeight.w600,
                                fontSize: captionSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            if (!isDiagnosed) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiagnoseScreen(
                          screening: screening,
                          patient: widget.patient,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.medical_services),
                  label: const Text("Provide Diagnosis"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}